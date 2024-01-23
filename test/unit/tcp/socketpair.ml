let () =
  Luv.TCP.socketpair `STREAM 0 |> ok "socketpair" @@ fun (socket_1, socket_2) ->

  Luv.TCP.init () |> ok "init 1" @@ fun tcp_1 ->
  Luv.TCP.open_ tcp_1 socket_1 |> ok "open_ 1" @@ fun () ->

  Luv.TCP.init () |> ok "init 2" @@ fun tcp_2 ->
  Luv.TCP.open_ tcp_2 socket_2 |> ok "open_ 2" @@ fun () ->

  Luv.Stream.write tcp_1 [Luv.Buffer.from_string "foo"] (fun _ _ -> ());
  Luv.Handle.close tcp_1 ignore;

  Luv.Stream.read_start tcp_2 begin fun result ->
    result |> ok "read_start" @@ fun b ->
    Printf.printf "%S\n" (Luv.Buffer.to_string b);
    Luv.Handle.close tcp_2 ignore
  end;

  Luv.Loop.run () |> ignore
