let () =
  Helpers.with_loop @@ fun loop ->
  Luv.Loop.(Luv.Loop.configure loop Luv.Loop.Option.block_signal 0)
  |> error [`EINVAL; `ENOSYS] "configure" @@ fun () ->
  print_endline "Ok"
