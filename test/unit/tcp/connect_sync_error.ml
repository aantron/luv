let () =
  Helpers.with_tcp @@ fun tcp ->

  Luv.Sockaddr.ipv4 "127.0.0.1" 5105 |> ok "ipv4" @@ fun address ->
  Luv.TCP.connect tcp address ignore;
  Luv.TCP.connect tcp address (fun result ->
    result |> error [`EALREADY; `EINVAL] "connect" @@ fun () ->
    print_endline "Ok");

  Luv.Loop.run () |> ignore
