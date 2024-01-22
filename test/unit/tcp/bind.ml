let () =
  Helpers.with_tcp @@ fun tcp ->

  Luv.Sockaddr.ipv4 "127.0.0.1" 5100 |> ok "ipv4" @@ fun address ->
  Luv.TCP.bind tcp address |> ok "bind" @@ fun () ->

  print_endline "Ok"
