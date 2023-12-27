(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let () =
  Helpers.with_loop @@ fun loop ->
  Luv.Loop.(Luv.Loop.configure loop Luv.Loop.Option.block_signal 0)
  |> error [`EINVAL; `ENOSYS] "configure" @@ fun () ->
  print_endline "Ok"
