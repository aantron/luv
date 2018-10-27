let () =
  print_endline "#include <caml/mlvalues.h>";
  print_endline "#include <caml/socketaddr.h>";
  print_endline "#include <uv.h>";
  print_endline "#include \"helpers.h\"";

  Cstubs_structs.write_c
    Format.std_formatter (module Luv_c_type_descriptions.Descriptions)
