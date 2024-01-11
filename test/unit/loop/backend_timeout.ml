let () =
  Helpers.with_loop @@ fun loop ->
  Luv.Loop.backend_timeout loop
  |> show_option @@ Printf.printf "%i\n"
