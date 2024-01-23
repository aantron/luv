let with_tcp f =
  Luv.TCP.init () |> ok "init" @@ fun tcp ->
  f tcp;
  Luv.Handle.close tcp ignore

let with_server_and_client ~port ~server ~client =
  Luv.Sockaddr.ipv4 "127.0.0.1" port |> ok "ipv4" @@ fun address ->

  Luv.TCP.init () |> ok "server init" @@ fun server_tcp ->
  Luv.TCP.bind server_tcp address |> ok "bind" @@ fun () ->
  Luv.Stream.listen server_tcp begin fun result ->
    result |> ok "listen" @@ fun () ->
    Luv.TCP.init () |> ok "accept init" @@ fun accept_tcp ->
    Luv.Stream.accept ~server:server_tcp ~client:accept_tcp
    |> ok "accept" @@ fun () ->
    server server_tcp accept_tcp
  end;

  Luv.TCP.init () |> ok "client init" @@ fun client_tcp ->
  Luv.TCP.connect client_tcp address begin fun result ->
    match result with
    | Ok () | Error `ECONNRESET -> client client_tcp address
    | _ -> result |> ok "connect" ignore
  end;

  Luv.Loop.run () |> ignore
