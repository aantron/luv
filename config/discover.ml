module C = Configurator.V1

let extra_libs c =
  match C.ocaml_config_var_exn c "system" with
    | "mingw64" -> ["-ldbghelp"; "-liphlpapi"; "-lole32"; "-lpsapi"; "-luserenv"]
    | _ -> []


let compiler_output_flag c =
  match C.ocaml_config_var_exn c "ccomp_type" with
    | "msvc" -> "-Fe:"
    | _ -> "-o"


let () =
  C.main ~name:"luv" (fun c ->
    C.Flags.write_sexp "extra_libs.sexp" (extra_libs c);
    C.Flags.write_lines "compiler_output_flag" [compiler_output_flag c];
  )
