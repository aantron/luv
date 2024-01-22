let () =
  Luv.Sockaddr.ipv4 "127.0.0.1" 5106 |> ok "ipv4" @@ fun address ->

  no_memory_leak begin fun _n ->
    Helpers.with_tcp @@ fun tcp ->
    Luv.TCP.connect tcp address ignore;
    Luv.TCP.connect tcp address ignore;
    Luv.Loop.run () |> ignore
  end;

  print_endline "End"
