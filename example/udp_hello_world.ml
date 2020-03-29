let () =
  let address = Luv.Sockaddr.ipv4 "127.0.0.1" 7000 |> Result.get_ok in
  let client = Luv.UDP.init () |> Result.get_ok in

  let message = Luv.Buffer.from_string "Hello, world!" in
  Luv.UDP.send client [message] address ignore;

  Luv.UDP.recv_start client begin function
    | Error e ->
      Printf.eprintf "Receive error: %s\n" (Luv.Error.strerror e);
      Luv.Handle.close client ignore
    | Ok (response, _server_address, _flags) ->
      print_endline (Luv.Buffer.to_string response);
      Luv.Handle.close client ignore
  end;

  ignore (Luv.Loop.run () : bool)
