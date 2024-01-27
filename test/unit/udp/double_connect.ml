let () =
  Helpers.with_udp @@ fun udp ->

  Luv.Sockaddr.ipv4 "127.0.0.1" 5208 |> ok "ipv4" @@ fun address ->
  Luv.UDP.bind udp address |> ok "bind" @@ fun () ->

  Luv.Sockaddr.ipv4 "127.0.0.1" 5209 |> ok "ipv4" @@ fun remote ->
  Luv.UDP.Connected.connect udp remote |> ok "connect" @@ fun () ->
  Luv.UDP.Connected.connect udp remote
  |> error [`EISCONN] "connect" @@ fun () ->

  print_endline "Ok"
