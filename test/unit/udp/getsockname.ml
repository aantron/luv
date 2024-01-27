let () =
  Helpers.with_udp @@ fun udp ->

  Luv.Sockaddr.ipv4 "127.0.0.1" 5201 |> ok "ipv4" @@ fun address ->
  Luv.UDP.bind udp address |> ok "bind" @@ fun () ->

  Luv.UDP.getsockname udp |> ok "getsockname" @@ fun address' ->

  let address = Luv.Sockaddr.to_string address in
  let address' = Luv.Sockaddr.to_string address' in

  Printf.printf "%b\n" (address' = address)
