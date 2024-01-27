let () =
  Helpers.with_pipe @@ fun pipe ->

  Luv.Pipe.bind pipe Helpers.filename |> ok "bind" @@ fun () ->
  Luv.Pipe.getsockname pipe |> ok "getsockname" @@ fun filename' ->

  Printf.printf "%b\n" (filename' = Helpers.filename)
