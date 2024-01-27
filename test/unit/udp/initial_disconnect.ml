let () =
  Helpers.with_udp @@ fun udp ->

  Luv.Sockaddr.ipv4 "127.0.0.1" 5210 |> ok "ipv4" @@ fun address ->
  Luv.UDP.bind udp address |> ok "bind" @@ fun () ->

  Luv.UDP.Connected.disconnect udp
  |> error [`ENOTCONN] "disconnect" @@ fun () ->

  print_endline "Ok"
