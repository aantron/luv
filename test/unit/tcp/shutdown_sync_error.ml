let () =
  Helpers.with_tcp @@ fun tcp ->

  Luv.Stream.shutdown tcp begin fun result ->
    result |> error [`ENOTCONN] "shutdown" @@ fun () ->
    print_endline "Ok"
  end
