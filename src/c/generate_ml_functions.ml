let () =
  print_endline "module Non_blocking =";
  print_endline "struct";

  Cstubs.write_ml
    Format.std_formatter
    ~prefix:Sys.argv.(1)
    (module Luv_c_function_descriptions.Descriptions);

  print_endline "end";
  print_newline ();
  print_endline "module Blocking =";
  print_endline "struct";

  Cstubs.write_ml
    ~concurrency:Cstubs.unlocked
    Format.std_formatter
    ~prefix:Sys.(argv.(1) ^ "_blocking")
    (module Luv_c_function_descriptions.Blocking);

  print_endline "end"
