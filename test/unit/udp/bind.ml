let () =
  Helpers.with_udp @@ fun udp ->

  Luv.Sockaddr.ipv4 "127.0.0.1" 5200 |> ok "ipv4" @@ fun address ->
  Luv.UDP.bind udp address |> ok "bind" @@ fun () ->

  print_endline "Ok"
