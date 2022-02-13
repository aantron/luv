module C = Configurator.V1

(** [uppercase_ascii] is equivalent to OCaml 4.03+; works on OCaml 4.02.0 *)
let uppercase_ascii s =
  let b_uppercase_ascii s = Bytes.map Char.uppercase_ascii s in
  b_uppercase_ascii (Bytes.of_string s) |> Bytes.to_string

let use_system_libuv =
  match Sys.getenv "LUV_USE_SYSTEM_LIBUV" with
  | "yes" -> true
  | _ -> false
  | exception Not_found -> false

(** [system_libuv_flags kind context_name] gets the value of the environment
    variable ["LUV_${kind}_LIBUV_${uppercase(sanitize(context_name))}"].

    For example, if [kind] is ["lib"] and [context_name] is ["default.android_aarch64"]
    then the result would be the value of the environment variable
    ["LUV_LIB_LIBUV_DEFAULT_ANDROID_AARCH64"]. *)
let system_libuv_flags ~kind ~context_name =
  let normalized_context_name =
    Str.(global_replace (regexp "[^A-Z0-9]") "_" (uppercase_ascii context_name))
  in
  let envvar_name =
    "LUV_" ^ uppercase_ascii kind ^ "_LIBUV_" ^ normalized_context_name
  in
  match Sys.getenv envvar_name with
  | value -> Some value
  | exception Not_found -> None

(** [split_on_semicolons s] splits a semi-colon separated string [s] *)
let split_on_semicolons s = Str.(split (regexp ";+") s)

(** [uv_lib ~context_name] gets the linker flags to link libuv.

    When the environment variable ["LUV_USE_SYSTEM_LIBUV"] is not ["yes"], there
    will be no linker flags.

    When the environment variable defined by [system_libuv_flags ~kind:"lib"] is non-empty, then
    those flags will be split by semicolons and used with all empty flags removed.

    Otherwise the default linker flags are [["-luv"]].

    In particular, if ["LUV_USE_SYSTEM_LIBUV"] is ["yes"] and
    [context_name] is ["default.windows"] then:

    * ["LUV_LIB_LIBUV_DEFAULT_WINDOWS"]=[""]  -> [["-luv"]]
    * ["LUV_LIB_LIBUV_DEFAULT_WINDOWS"]=[";"] -> [[]]
    * ["LUV_LIB_LIBUV_DEFAULT_WINDOWS"]=["-L/usr/lib;-llibuv"] -> [["-L/usr/lib"; "-llibuv"]]
    * ["LUV_LIB_LIBUV_DEFAULT_WINDOWS"]=[";-llibuv"] -> [["-llibuv"]]

    In the above rules, an undefined environment variable and an empty environment
    variable are treated the same. *)
let uv_lib ~context_name =
  match (use_system_libuv, system_libuv_flags ~kind:"lib" ~context_name) with
  | false, _ -> []
  | true, Some flags when flags <> "" ->
      split_on_semicolons flags |> List.filter (fun i -> i <> "")
  | true, Some _ | true, None -> [ "-luv" ]

(** [uv_include ~context_name ~vendor_dir] gets the compiler flags to include compile libuv consuming code.

    ctypes and stdlib headers are always included.

    When the environment variable ["LUV_USE_SYSTEM_LIBUV"] is not ["yes"], there
    will be extra include flags: -I vendor/libuv/include

    When the environment variable defined by [system_libuv_flags ~kind:"include"] is non-empty, then
    those include flags will be split by semicolons and used with all empty flags removed.

    Otherwise there are no extra include flags.

    See [uv_lib] for how the semicolon splitting works. For example:

    * ["LUV_INCLUDE_LIBUV_DEFAULT_WINDOWS"]=["-I;C:\\Program Files\\include"] -> [["-I"; "C:\\Program Files\\include"]] *)
let uv_include ~context_name ~vendor_dir =
  match
    (use_system_libuv, system_libuv_flags ~kind:"include" ~context_name)
  with
  | false, _ -> ["-I"; Filename.concat vendor_dir "include"]
  | true, Some flags when flags <> "" ->
      split_on_semicolons flags
      |> List.filter (fun s -> s <> "")
  | true, Some _ | true, None -> []

(** [compile_c ~context_name ~vendor_dir] is the contents of a portable shell script that compiles C code.

    The usage for the shell script is:
    {v
      compile_c.sh C_SOURCE_FILE INCLUDEDIR_CTYPES TARGET CC CFLAGS
    v}

    The TARGET is the destination executable file.

    The CC and CFLAGS can be the %{cc} compiler and flags from
    https://dune.readthedocs.io/en/stable/concepts.html#flags

    The shell script will include the [uv_include] flags. *)
let compile_c c ~context_name ~vendor_dir =
  let oflag =
    match C.ocaml_config_var c "ccomp_type" with
    | Some "msvc" -> "/Fe"
    | _ -> "-o "
  in
  let stdlib_where = C.ocaml_config_var_exn c "standard_library" in
  let extra_flags =
    uv_include ~context_name ~vendor_dir
    |> List.map (fun s -> "\"" ^ String.escaped s ^ "\"")
    |> String.concat " "
  in
  Format.sprintf "\
#!/bin/sh
# context=%s
set -euf
src=$1; shift
ctypes=$1; shift
target=$1; shift
\"$@\" \"$src\" -I \"$ctypes\" -I \"%s\" %s %s\"$target\"
" context_name stdlib_where extra_flags oflag

let () =
  let context_name = ref "default" in
  let vendor_dir =
    ref
      Filename.(concat (concat (concat (Sys.getcwd ()) "..") "vendor") "libuv")
  in
  C.main
    ~args:[ 
      ("-context", Arg.String (fun s -> context_name := s), "Dune context");
      ("-vendor-dir", Arg.String (fun s -> vendor_dir := s), "Absolute path to vendor/libuv");
    ]
    ~name:""
    (fun c ->
      C.Flags.write_sexp "uv_lib.sexp" (uv_lib ~context_name:!context_name);
      C.Flags.write_sexp "uv_include.sexp" (uv_include ~context_name:!context_name ~vendor_dir:!vendor_dir);
      (* binary mode so Windows does not use CRLF *)
      let oc = open_out_bin "compile_c.sh" in
      output_string oc (compile_c c ~context_name:!context_name ~vendor_dir:!vendor_dir);
      close_out oc)
