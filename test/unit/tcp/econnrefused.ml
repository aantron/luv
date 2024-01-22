let () =
  Helpers.with_tcp @@ fun tcp ->

  Luv.Sockaddr.ipv4 "127.0.0.1" 5102 |> ok "ipv4" @@ fun address ->
  Luv.TCP.connect tcp address (fun result ->
    result |> error [`ECONNREFUSED] "connect" @@ fun () ->
    print_endline "Ok");

  Luv.Loop.run () |> ignore
