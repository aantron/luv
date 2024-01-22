let () =
  Helpers.with_tcp @@ fun tcp ->

  Luv.Sockaddr.ipv4 "127.0.0.1" 5101 |> ok "ipv4" @@ fun address ->
  Luv.TCP.bind tcp address |> ok "bind" @@ fun () ->

  Luv.TCP.getsockname tcp |> ok "getsockname" @@ fun address' ->

  let address = Luv.Sockaddr.to_string address in
  let address' = Luv.Sockaddr.to_string address' in

  Printf.printf "%b\n" (address' = address)
