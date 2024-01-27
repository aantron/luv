let () =
  Helpers.with_pipe @@ fun pipe ->
  Luv.Pipe.chmod pipe [`READABLE] |> error [`EBADF] "chmod" @@ fun () ->
  print_endline "Ok"
