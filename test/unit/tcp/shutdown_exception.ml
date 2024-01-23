let () =
  Luv.Error.set_on_unhandled_exception (function
    | Exit -> print_endline "Ok"
    | _ -> ());

  Helpers.with_server_and_client
    ~port:5118
    ~server:begin fun server_tcp accept_tcp ->
      Luv.Stream.shutdown accept_tcp begin fun result ->
        result |> ok "shutdown" @@ fun b ->
        Luv.Handle.close accept_tcp ignore;
        Luv.Handle.close server_tcp ignore;
        raise Exit
      end
    end
    ~client:(fun client_tcp _ -> Luv.Handle.close client_tcp ignore)
