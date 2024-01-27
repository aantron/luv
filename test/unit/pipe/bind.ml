let () =
  Helpers.with_pipe @@ fun pipe ->
  Luv.Pipe.bind pipe Helpers.filename |> ok "bind" @@ fun () ->
  print_endline "Ok"
