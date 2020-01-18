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


  (* We use this call to Lwt.async just to "ignore" the Lwt promise that
     represents (most of) the process of doing a GET request.

     The call to Luv.Lwt.run () below automatically "knows" to wait for all
     outstanding I/O, so, unlike with Lwt_main.run, we don't have to pass it a
     promise to tell it when to exit. *)
  Lwt.async begin fun () ->


    (* Do a DNS lookup on the URL we are asked to retrieve. *)

    let%lwt addr_infos =
      Luv.Lwt.DNS.getaddrinfo ~family:`INET ~node:url ~service:"80" () in
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
    let%lwt result = Luv.Lwt.TCP.connect socket addr_info.addr in
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
    let%lwt result, written =
      Luv.Lwt.Stream.write socket [Luv.Buffer.from_string request] in
    begin match result with
    | Result.Ok () -> ()
    | Result.Error error ->
      Printf.eprintf "Could not send request: %s" (Luv.Error.strerror error);
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
        print_string (Luv.Buffer.to_string buffer)
      | Result.Error `EOF ->
        Luv.Handle.close socket ignore
      | Result.Error error ->
        Printf.eprintf
          "Could not read from socket: %s" (Luv.Error.strerror error);
        exit 1
    end;


    (* This promise actually resolves right after the request is written and the
       read_start loop is set up, but *before* any response data is read. That's
       okay, though, because we don't care about this promise. We just need it
       to satisfy the type of bind (which we are using in its let%lwt form). As
       suggested above, it's not this promise which controls when Luv.Lwt.run
       exits, but whether there is either (1) any pending I/O or (2) any
       callbacks left to be run. In the case of this program, there will be
       pending I/O until the response is fully read, so read_start implicitly,
       automatically, controls when Lwt.Luv.run exits, by calling
       Luv.Handle.close to remove the pending read I/O. *)
    Lwt.return ()
  end;


  (* Wait for all the I/O to finish. The calls to select, epoll, kevent, etc.,
     happen here. *)

  Luv.Lwt.run ()
