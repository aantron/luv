let () =
  Helpers.with_server_and_client ~for_handle_passing:true ()
    ~server:begin fun server_pipe accept_pipe ->
      Luv.Stream.read_start accept_pipe begin fun result ->
        result |> ok "read_start" @@ fun b ->
        Printf.printf "%S\n" (Luv.Buffer.to_string b);
        begin match Luv.Pipe.receive_handle accept_pipe with
        | `TCP receive ->
          Luv.TCP.init () |> ok "received tcp init" @@ fun tcp ->
          receive tcp |> ok "receive" @@ fun () ->
          Luv.Handle.close tcp ignore;
          print_endline "Ok"
        | `Pipe _ ->
          print_endline "Got a pipe"
        | `None ->
          print_endline "No handle"
        end;
        Luv.Handle.close accept_pipe ignore;
        Luv.Handle.close server_pipe ignore
      end
    end
    ~client:begin fun client_pipe ->
      Luv.TCP.init () |> ok "tcp init" @@ fun tcp ->
      Luv.Sockaddr.ipv4 "127.0.0.1" 5199 |> ok "ipv4" @@ fun address ->
      Luv.TCP.bind tcp address |> ok "tcp bind" @@ fun () ->

      let b = Luv.Buffer.from_string "foo" in
      let send_handle = tcp in
      Luv.Stream.write2 client_pipe [b] ~send_handle begin fun result count ->
        Luv.Handle.close client_pipe ignore;
        result |> ok "write" @@ fun () ->
        Printf.printf "%i\n" count
      end
    end
