(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let () =
  (* Process command-line arguments. *)

  let url =
    try Sys.argv.(1)
    with Invalid_argument _ ->
      Printf.eprintf "Usage: %s URL [PATH]\n" (Filename.basename Sys.argv.(0));
      exit 1
  in
  let path =
    try Sys.argv.(2)
    with Invalid_argument _ -> "/"
  in


  (* Do a DNS lookup on the URL we are asked to retrieve. *)

  Luv.DNS.getaddrinfo ~family:`INET ~node:url ~service:"80" ()
      begin fun addr_infos ->
    let addr_info =
      match addr_infos with
      | Result.Ok (first::_) -> first
      | Result.Ok [] ->
        (* Not sure if Result.Ok is actually possible with the empty list. *)
        Printf.eprintf "Could not resolve %s\n" url;
        exit 1
      | Result.Error error ->
        Printf.eprintf
          "Could not resolve %s: %s\n" url (Luv.Error.strerror error);
        exit 1
    in


    (* Create the TCP socket and connect it. *)

    let socket =
      match Luv.TCP.init () with
      | Result.Ok socket -> socket
      | Result.Error error ->
        Printf.eprintf
          "Could not create TCP socket: %s\n" (Luv.Error.strerror error);
        exit 1
    in
    Luv.TCP.connect socket addr_info.addr begin fun result ->
      begin match result with
      | Result.Ok () -> ()
      | Result.Error error ->
        Printf.eprintf
          "Could not connect to %s: %s\n" url (Luv.Error.strerror error);
        exit 1
      end;


      (* Write the GET request. *)

      let request =
        Printf.sprintf "GET %s HTTP/1.1\r\nConnection: close\r\n\r\n" path in
      Luv.Stream.write socket [Luv.Bigstring.from_string request]
          begin fun result written ->
        begin match result with
        | Result.Ok () -> ()
        | Result.Error error ->
          Printf.eprintf "Could not send request: %s"
            (Luv.Error.strerror error);
          exit 1
        end;
        if written <> String.length request then
        begin
          prerr_endline "Could not send request";
          exit 1
        end;


        (* Read the response until the server closes the socket. *)

        Luv.Stream.read_start socket begin fun result ->
          match result with
          | Result.Ok buffer ->
            print_string (Luv.Bigstring.to_string buffer)
          | Result.Error `EOF ->
            Luv.Handle.close socket ignore
          | Result.Error error ->
            Printf.eprintf
              "Could not read from socket: %s" (Luv.Error.strerror error);
            exit 1
        end;
      end
    end
  end;

  ignore (Luv.Loop.run ())
