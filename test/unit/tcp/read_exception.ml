let () =
  Luv.Error.set_on_unhandled_exception (function
    | Exit -> print_endline "Ok"
    | _ -> ());

  Helpers.with_server_and_client
    ~port:5114
    ~server:begin fun server_tcp accept_tcp ->
      Luv.Stream.read_start accept_tcp begin fun result ->
        result |> ok "read_start" @@ fun b ->
        Luv.Handle.close accept_tcp ignore;
        Luv.Handle.close server_tcp ignore;
        raise Exit
      end
    end
    ~client:begin fun client_tcp _ ->
      let b = Luv.Buffer.from_string "f" in
      Luv.Stream.write client_tcp [b] begin fun result count ->
        result |> ok "write" @@ fun () ->
        Printf.printf "%i\n" count
      end
    end
