let () =
  Luv.DNS.getaddrinfo ~family:`INET ~node:"google.com" ~service:"80" ()
      begin fun result ->

    let address = (List.hd (Result.get_ok result)).addr in
    let socket = Luv.TCP.init () |> Result.get_ok in
    Luv.TCP.connect socket address begin fun _ ->

      Luv.Stream.write socket [Luv.Buffer.from_string "GET / HTTP/1.1\r\n\r\n"]
        (fun _ _ -> Luv.Stream.shutdown socket ignore);

      Luv.Stream.read_start socket (function
        | Error `EOF -> Luv.Handle.close socket ignore
        | Error _ -> exit 2
        | Ok response -> print_string (Luv.Buffer.to_string response))

    end
  end;

  ignore (Luv.Loop.run () : bool)
