let () =
  Helpers.with_server_and_client ()
    ~server:begin fun server_pipe accept_pipe ->
      Luv.Stream.read_start accept_pipe begin fun result ->
        result |> ok "read_start" @@ fun b ->
        Printf.printf "%S\n" (Luv.Buffer.to_string b);
        Luv.Handle.close accept_pipe ignore;
        Luv.Handle.close server_pipe ignore
      end
    end
    ~client:begin fun client_pipe ->
      let b1 = Luv.Buffer.from_string "fo" in
      let b2 = Luv.Buffer.from_string "o" in

      Luv.Stream.write client_pipe [b1; b2] begin fun result count ->
        Luv.Handle.close client_pipe ignore;
        result |> ok "write" @@ fun () ->
        Printf.printf "%i\n" count
      end
    end
