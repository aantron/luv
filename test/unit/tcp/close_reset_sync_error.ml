let () =
  Helpers.with_tcp @@ fun tcp ->

  Luv.TCP.close_reset tcp begin fun result ->
    result |> error [`EBADF; `ENOTSOCK] "close_reset" @@ fun () ->
    print_endline "Ok"
  end
