let () =
  Cstubs.write_ml
    Format.std_formatter
    ~prefix:Sys.argv.(1)
    (module Luv_ffi_function_descriptions.Make)
