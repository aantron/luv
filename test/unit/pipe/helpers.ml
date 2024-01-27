let filename =
  if Sys.win32 then
    {|\\.\pipe\pipe|}
  else
    "pipe"

let with_pipe f =
  Luv.Pipe.init () |> ok "init" @@ fun tcp ->
  f tcp;
  Luv.Handle.close tcp ignore

let with_server_and_client ?(for_handle_passing = false) () ~server ~client =
  Luv.Pipe.init () |> ok "server init" @@ fun server_pipe ->
  Luv.Pipe.bind server_pipe filename |> ok "bind" @@ fun () ->
  Luv.Stream.listen server_pipe begin fun result ->
    result |> ok "listen" @@ fun () ->
    Luv.Pipe.init ~for_handle_passing ()
    |> ok "accept init" @@ fun accept_pipe ->
    Luv.Stream.accept ~server:server_pipe ~client:accept_pipe
    |> ok "accept" @@ fun () ->
    server server_pipe accept_pipe
  end;

  Luv.Pipe.init ~for_handle_passing () |> ok "client init" @@ fun client_pipe ->
  Luv.Pipe.connect client_pipe filename begin fun result ->
    result |> ok "connect" @@ fun () ->
    client client_pipe
  end;

  Luv.Loop.run () |> ignore
