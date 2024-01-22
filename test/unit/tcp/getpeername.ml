let () =
  Helpers.with_server_and_client
    ~port:5109
    ~server:begin fun server_tcp accept_tcp ->
      Luv.Handle.close server_tcp ignore
    end
    ~client:begin fun client_tcp address ->
      Luv.TCP.getpeername client_tcp |> ok "getpeername" @@ fun address' ->
      let address = Luv.Sockaddr.to_string address in
      let address' = Luv.Sockaddr.to_string address' in
      Printf.printf "%b\n" (address' = address)
    end
