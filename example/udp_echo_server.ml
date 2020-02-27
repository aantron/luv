let () =
  let address = Luv.Sockaddr.ipv4 "127.0.0.1" 7000 |> Result.get_ok in
  let server = Luv.UDP.init () |> Result.get_ok in
  ignore (Luv.UDP.bind server address);

  Luv.UDP.recv_start server begin function
    | Error e ->
      Printf.eprintf "Receive error: %s\n" (Luv.Error.strerror e)
    | Ok (_, None, _) ->
      ()
    | Ok (buffer, Some client_address, _flags) ->
      Luv.UDP.send server [buffer] client_address ignore
  end;

  ignore (Luv.Loop.run ())
