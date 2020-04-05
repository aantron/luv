(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let filename = "fs_event"

let () =
  Printf.printf "start of test %b\n%!" (Sys.file_exists filename);

  open_out filename |> close_out;

  let start = Unix.gettimeofday () in

  Printf.printf "touch %f\n%!" ((Unix.gettimeofday () -. start) *. 1e3);
  let oc = open_out filename in
  Printf.printf "write %f\n%!" ((Unix.gettimeofday () -. start) *. 1e3);
  let () = Printf.fprintf oc "foo" in

  Printf.printf "close %f\n%!" ((Unix.gettimeofday () -. start) *. 1e3);
  close_out oc;

  Printf.printf "after close %f\n%!" ((Unix.gettimeofday () -. start) *. 1e3);

  if Sys.file_exists filename then
    Sys.remove filename