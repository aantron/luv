(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let () =
  Helpers.with_loop @@ fun loop ->
  let initial = Luv.Loop.now loop in
  Unix.sleepf 0.1;
  Luv.Loop.update_time loop;
  let final = Luv.Loop.now loop in
  if Unsigned.UInt64.(to_int (sub final initial)) >= 100 then
    print_endline "Ok"
  else
    print_endline "Error: not updated"
