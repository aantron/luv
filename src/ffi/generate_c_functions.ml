let () =
  print_endline "#include <caml/mlvalues.h>";
  print_endline "#include <caml/socketaddr.h>";
  print_endline "#include <uv.h>";
  print_endline "#include \"trampolines.h\"";

  Cstubs.write_c
    Format.std_formatter
    ~prefix:Sys.argv.(1)
    (module Luv_ffi_function_descriptions.Make)
