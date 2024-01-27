let () =
  Helpers.with_server_and_client ()
    ~server:begin fun server_pipe accept_pipe ->
      prerr_endline "Accepted";
      Luv.Handle.close server_pipe ignore
    end
    ~client:begin fun client_pipe ->
      Luv.Handle.close client_pipe ignore
    end
