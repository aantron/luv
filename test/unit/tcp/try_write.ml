let () =
  Helpers.with_server_and_client
    ~port:5116
    ~server:begin fun server_tcp accept_tcp ->
      Luv.Stream.read_start accept_tcp begin fun result ->
        result |> ok "read_start" @@ fun b ->
        Printf.printf "%S\n" (Luv.Buffer.to_string b);
        Luv.Handle.close accept_tcp ignore;
        Luv.Handle.close server_tcp ignore
      end
    end
    ~client:begin fun client_tcp _ ->
      let b1 = Luv.Buffer.from_string "fo" in
      let b2 = Luv.Buffer.from_string "o" in
      Luv.Stream.try_write client_tcp [b1; b2]
      |> ok "try_write" @@ fun count ->
      Printf.printf "%i\n" count
    end
