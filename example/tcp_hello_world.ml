let () =
  let address = Luv.Sockaddr.ipv4 "127.0.0.1" 7000 |> Result.get_ok in
  let client = Luv.TCP.init () |> Result.get_ok in

  Luv.TCP.connect client address begin function
    | Error e ->
      Printf.eprintf "Connect error: %s\n" (Luv.Error.strerror e)
    | Ok () ->
      let message = Luv.Buffer.from_string "Hello, world!" in
      Luv.Stream.write client [message] (fun _result _bytes_written ->
        Luv.Stream.shutdown client ignore);

      Luv.Stream.read_start client begin function
        | Error `EOF ->
          Luv.Handle.close client ignore
        | Error e ->
          Printf.eprintf "Read error: %s\n" (Luv.Error.strerror e);
          Luv.Handle.close client ignore
        | Ok response ->
          print_endline (Luv.Buffer.to_string response)
      end
  end;

  ignore (Luv.Loop.run ())
