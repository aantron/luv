let () =
  Helpers.with_server_and_client
    ~port:5108
    ~server:begin fun server_tcp accept_tcp ->
      prerr_endline "Accepted";
      Luv.Handle.close server_tcp ignore
    end
    ~client:begin fun client_tcp _ ->
      prerr_endline "Connected"
    end
