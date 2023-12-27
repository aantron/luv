(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let check = if not Sys.win32 then ok else error [`ENOSYS]

let () =
  Helpers.with_loop @@ fun loop ->
  Luv.Loop.(configure loop Option.block_signal Option.sigprof)
  |> check "configure" @@ fun () ->
  print_endline "Ok"
