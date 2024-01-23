let () =
  Helpers.with_server_and_client
    ~port:5119
    ~server:begin fun server_tcp accept_tcp ->
      Luv.TCP.close_reset accept_tcp begin fun result ->
        result |> ok "close_reset" @@ fun () ->
        Luv.Handle.close server_tcp ignore;
        print_endline "Ok"
      end
    end
    ~client:(fun client_tcp _ -> Luv.Handle.close client_tcp ignore)
