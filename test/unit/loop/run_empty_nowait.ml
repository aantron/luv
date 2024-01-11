let () =
  Helpers.with_loop @@ fun loop ->
  Luv.Loop.run ~loop ~mode:`NOWAIT ()
  |> Printf.printf "%b\n"
