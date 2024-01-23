let () =
  Helpers.with_tcp @@ fun tcp ->

  Luv.Stream.try_write tcp [Luv.Buffer.from_string ""]
  |> error [`EBADF; `EPIPE] "write" @@ fun () ->
  print_endline "Ok"
