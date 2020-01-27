let () =
  Luv.DNS.getaddrinfo ~family:`INET ~node:Sys.argv.(1) () begin function
    | Error e ->
      Printf.eprintf "Cannot resolve host: %s\n" (Luv.Error.strerror e)
    | Ok addr_infos ->
      print_endline
        (Option.get (Luv.Sockaddr.to_string (List.hd addr_infos).addr))
  end;

  ignore (Luv.Loop.run ())
