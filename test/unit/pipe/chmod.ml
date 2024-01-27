let () =
  Helpers.with_pipe @@ fun pipe ->
  Luv.Pipe.bind pipe Helpers.filename |> ok "bind" @@ fun () ->
  Luv.Pipe.chmod pipe [`READABLE] |> ok "chmod" @@ fun () ->
  print_endline "Ok"
