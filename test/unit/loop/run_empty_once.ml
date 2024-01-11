let () =
  Helpers.with_loop @@ fun loop ->
  Luv.Loop.run ~loop ~mode:`ONCE ()
  |> Printf.printf "%b\n"
