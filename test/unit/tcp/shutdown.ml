let () =
  Helpers.with_server_and_client
    ~port:5117
    ~server:begin fun server_tcp accept_tcp ->
      Luv.Stream.shutdown accept_tcp begin fun result ->
        result |> ok "server shutdown" @@ fun () ->
        Luv.Handle.close accept_tcp ignore;
        Luv.Handle.close server_tcp ignore;
        print_endline "Server ok"
      end
    end
    ~client:begin fun client_tcp _ ->
      Luv.Stream.shutdown client_tcp begin fun result ->
        result |> ok "client shutdown" @@ fun () ->
        Luv.Handle.close client_tcp ignore;
        print_endline "Client ok"
      end
    end
