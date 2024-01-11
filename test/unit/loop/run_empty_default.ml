let () =
  Helpers.with_loop @@ fun loop ->
  Luv.Loop.run ~loop ~mode:`DEFAULT ()
  |> Printf.printf "%b\n"
