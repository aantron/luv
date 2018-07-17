(* TODO Send to jbuild file for reading how this is called. *)

let () =
  Cstubs.write_ml
    (* ~concurrency:Cstubs.unlocked *) (* TODO *)
    Format.std_formatter
    ~prefix:Sys.argv.(1)
    (module Libuv_functions.Make)
