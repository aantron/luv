let () =
  Luv.Sockaddr.ipv4 "127.0.0.1" 5104 |> ok "ipv4" @@ fun address ->

  no_memory_leak begin fun _n ->
    Helpers.with_tcp @@ fun tcp ->
    let callback = fresh_callback () in
    Luv.TCP.connect tcp address (fun _ -> callback ());
    Luv.Loop.run () |> ignore
  end;

  print_endline "End"
