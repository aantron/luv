(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let () =
  print_endline "#include \"windows_version.h\"";
  print_endline "#include <uv.h>";
  print_endline "#include <caml/mlvalues.h>";
  print_endline "#include <caml/socketaddr.h>";
  print_endline "#include \"helpers.h\"";

  Cstubs_structs.write_c
    Format.std_formatter (module Luv_c_type_descriptions.Descriptions)
