let () =
  Helpers.with_server_and_client
    ~port:5113
    ~server:begin fun server_tcp accept_tcp ->
      Luv.Stream.read_start accept_tcp begin fun result ->
        result |> error [`EOF] "read_start" @@ fun () ->
        Luv.Handle.close accept_tcp ignore;
        Luv.Handle.close server_tcp ignore;
        print_endline "Ok"
      end
    end
    ~client:(fun client_tcp _ -> Luv.Handle.close client_tcp ignore)
