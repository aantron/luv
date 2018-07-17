(* TODO Send to jbuild file for reading how this is called. *)

let () =
  print_endline "#include <caml/mlvalues.h>";
  print_endline "#include <caml/socketaddr.h>";
  print_endline "#include <uv.h>";
  print_endline "#include \"trampolines.h\"";

  Cstubs.write_c
    (* ~concurrency:Cstubs.unlocked *) (* TODO *)
    Format.std_formatter
    ~prefix:Sys.argv.(1)
    (module Libuv_functions.Make)
