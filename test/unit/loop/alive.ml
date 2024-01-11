let () =
  Helpers.with_loop @@ fun loop ->
  Luv.Loop.alive loop
  |> Printf.printf "%b\n"
