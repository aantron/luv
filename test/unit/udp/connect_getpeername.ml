let () =
  Helpers.with_udp @@ fun udp ->

  Luv.Sockaddr.ipv4 "127.0.0.1" 5206 |> ok "ipv4" @@ fun address ->
  Luv.UDP.bind udp address |> ok "bind" @@ fun () ->
  Luv.UDP.Connected.getpeername udp
  |> error [`ENOTCONN] "getpeername" @@ fun () ->

  Luv.Sockaddr.ipv4 "127.0.0.1" 5207 |> ok "ipv4" @@ fun remote ->
  Luv.UDP.Connected.connect udp remote |> ok "connect" @@ fun () ->
  Luv.UDP.Connected.getpeername udp |> ok "getpeername" @@ fun remote' ->

  let remote = Luv.Sockaddr.to_string remote in
  let remote' = Luv.Sockaddr.to_string remote' in

  Printf.printf "%b\n" (remote' = remote);

  Luv.UDP.Connected.disconnect udp |> ok "disconnect" @@ fun () ->
  Luv.UDP.Connected.getpeername udp
  |> error [`ENOTCONN] "getpeername" @@ fun () ->

  print_endline "Ok"
