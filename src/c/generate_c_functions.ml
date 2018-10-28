let () =
  print_endline "#include <memory.h>";
  print_endline "#include <caml/mlvalues.h>";
  print_endline "#include <caml/socketaddr.h>";
  print_endline "#include <caml/threads.h>";
  print_endline "#include <uv.h>";
  print_endline "#include \"helpers.h\"";

  Cstubs.write_c
    Format.std_formatter
    ~prefix:Sys.argv.(1)
    (module Luv_c_function_descriptions.Descriptions);

  Cstubs.write_c
    ~concurrency:Cstubs.unlocked
    Format.std_formatter
    ~prefix:(Sys.argv.(1) ^ "_blocking")
    (module Luv_c_function_descriptions.Blocking)
