let check = if not Sys.win32 then ok else error [`ENOSYS]

let () =
  Helpers.with_loop @@ fun loop ->
  Luv.Loop.(configure loop Option.block_signal Option.sigprof)
  |> check "configure" @@ fun () ->
  print_endline "Ok"
