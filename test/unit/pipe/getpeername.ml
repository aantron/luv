let () =
  Helpers.with_server_and_client ()
    ~server:begin fun server_pipe accept_pipe ->
      Luv.Handle.close server_pipe ignore
    end
    ~client:begin fun client_pipe ->
      Luv.Pipe.getpeername client_pipe |> ok "getpeername" @@ fun filename' ->
      Printf.printf "%b\n" (filename' = Helpers.filename)
    end
