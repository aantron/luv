let () =
  print_endline "#include <caml/mlvalues.h>";
  print_endline "#include <caml/socketaddr.h>";
  print_endline "#include <uv.h>";
  print_endline "#include \"trampolines.h\"";

  Cstubs_structs.write_c
    Format.std_formatter (module Libuv_types.Make)
