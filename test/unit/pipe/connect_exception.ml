let () =
  Luv.Error.set_on_unhandled_exception (function
    | Exit -> print_endline "Ok"; exit 0
    | _ -> ());

  Helpers.with_server_and_client ()
    ~server:(fun server_pipe accept_pipe -> Luv.Handle.close server_pipe ignore)
    ~client:(fun client_pipe -> raise Exit)
