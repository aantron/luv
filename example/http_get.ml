let () =
  let host = Sys.argv.(1) in
  let path = Sys.argv.(2) in

  Luv.DNS.getaddrinfo ~family:`INET ~node:host ~service:"80" () begin function
    | Error e ->
      Printf.eprintf "Cannot resolve host: %s\n" (Luv.Error.strerror e)
    | Ok addr_infos ->
      let address = (List.hd addr_infos).addr in

      let socket = Luv.TCP.init () |> Stdlib.Result.get_ok in
      Luv.TCP.connect socket address begin function
        | Error e ->
          Printf.eprintf "Cannot connect: %s\n" (Luv.Error.strerror e)
        | Ok () ->

          let request =
            Printf.ksprintf
              Luv.Buffer.from_string "GET %s HTTP/1.1\r\n\r\n" path
          in
          Luv.Stream.write socket [request] (fun _ _ ->
            Luv.Stream.shutdown socket ignore);

          Luv.Stream.read_start socket begin function
            | Error `EOF ->
              Luv.Handle.close socket ignore
            | Error e ->
              Printf.eprintf "Read error: %s\n" (Luv.Error.strerror e);
              Luv.Handle.close socket ignore
            | Ok response ->
              print_endline (Luv.Buffer.to_string response)
          end
      end
  end;

  ignore (Luv.Loop.run ())
