let () =
  let errors = if Sys.win32 then [`ECONNREFUSED] else [`ECANCELED] in

  Helpers.with_tcp @@ fun tcp ->

  Luv.Sockaddr.ipv4 "127.0.0.1" 5107 |> ok "ipv4" @@ fun address ->
  Luv.TCP.connect tcp address (fun result ->
    result |> error errors "connect" @@ fun () ->
    print_endline "Ok");

  Luv.Handle.close tcp ignore;
  Luv.Loop.run () |> ignore
