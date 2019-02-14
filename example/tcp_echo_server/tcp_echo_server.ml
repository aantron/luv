let () =
  (* Create the server handle. *)

  let server =
    match Luv.TCP.init () with
    | Ok server -> server
    | Error error_code ->
      Printf.eprintf
        "Could not create server handle: %s" (Luv.Error.strerror error_code);
      exit 1
  in

  (* Bind to localhost:5000. *)

  let interface = "127.0.0.1" in
  let port = 5000 in

  let sockaddr =
    match Luv.Sockaddr.ipv4 interface port with
    | Ok sockaddr -> sockaddr
    | Error error_code ->
      Printf.eprintf
        "Could not create sockaddr: %s" (Luv.Error.strerror error_code);
      exit 1
  in

  let result = Luv.TCP.bind server sockaddr in
  if result <> Luv.Error.success then begin
    Printf.eprintf
      "Could not bind to %s:%i: %s" interface port (Luv.Error.strerror result);
    exit 1
  end;


  (* For each connection, echo all data received, until the client closes the
     connection. *)

  Luv.Stream.listen server begin fun result ->
    if result <> Luv.Error.success then begin
      Printf.eprintf "Error while listening: %s" (Luv.Error.strerror result);
      exit 1
    end;

    let client =
      match Luv.TCP.init () with
      | Ok client -> client
      | Error error_code ->
        Printf.eprintf
          "Could not create client handle: %s" (Luv.Error.strerror error_code);
        exit 1
    in

    let result = Luv.Stream.accept ~server ~client in
    if result <> Luv.Error.success then begin
      Printf.eprintf "Error accepting client: %s" (Luv.Error.strerror result);
      exit 1
    end;

    Luv.Stream.read_start client begin fun result ->
      match result with
      | Error error_code when error_code = Luv.Error.eof ->
        Luv.Handle.close client

      | Error error_code ->
        Printf.eprintf "Error reading: %s" (Luv.Error.strerror error_code);
        exit 1

      | Ok data ->
        Luv.Stream.write client [data] begin fun result _ ->
          if result <> Luv.Error.success then begin
            Printf.eprintf "Error writing: %s" (Luv.Error.strerror result);
            exit 1
          end
        end
      end
    end
  in


  (* Run forever. *)

  ignore (Luv.Loop.run ())
