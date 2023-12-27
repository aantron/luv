(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let () =
  Helpers.with_loop @@ fun loop ->
  Luv.Loop.backend_timeout loop
  |> show_option @@ Printf.printf "%i\n"
