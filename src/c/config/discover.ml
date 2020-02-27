
type os =
    | Windows
    | Mac
    | Linux
    | Unknown

let uname () =
    let ic = Unix.open_process_in "uname" in
    let uname = input_line ic in
    let () = close_in ic in
    uname;;

let get_os =
    match Sys.os_type with
    | "Win32" -> Windows
    | _ -> match uname () with
        | "Darwin" -> Mac
        | "Linux" -> Linux
        | _ -> Unknown

let libPath = "-L" ^ (Sys.getenv "LIBUV_LIB_PATH")

let ccopt s = ["-ccopt"; s]
let cclib s = ["-cclib"; s]

let c_flags = ["-I"; (Sys.getenv "LIBUV_INCLUDE_PATH");]

let c_flags = match get_os with
    | Linux -> c_flags @ ["-fPIC"]
    | _ -> c_flags
;;

let flags =
    []
        @ ccopt(libPath)
        @ cclib("-luv")
;;

Configurator.V1.Flags.write_sexp "c_flags.sexp" c_flags;
Configurator.V1.Flags.write_sexp "flags.sexp" flags;
