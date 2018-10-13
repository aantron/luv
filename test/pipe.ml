open Test_helpers

let filename = "pipe"

let with_pipe f =
  let pipe =
    Luv.Pipe.init ()
    |> check_success_result "init"
  in

  f pipe;

  Luv.Handle.close pipe;
  run ();

  Alcotest.(check bool) "file deleted" false (Sys.file_exists filename)

let with_server_and_client ?for_handle_passing () ~server_logic ~client_logic =
  let server =
    Luv.Pipe.init ?for_handle_passing ()
    |> check_success_result "server init"
  in
  Luv.Pipe.bind server filename |> check_success "bind";
  Luv.Stream.listen server begin fun result ->
    check_success "listen" result;
    let client =
      Luv.Pipe.init ?for_handle_passing ()
      |> check_success_result "remote client init"
    in
    Luv.Stream.accept ~server ~client |> check_success "accept";
    server_logic server client
  end;

  let client =
    Luv.Pipe.init ?for_handle_passing ()
    |> check_success_result "client init"
  in
  Luv.Pipe.connect client filename begin fun result ->
    check_success "connect" result;
    client_logic client
  end;

  run ();

  Alcotest.(check bool) "file deleted" false (Sys.file_exists filename)

let tests = [
  "pipe", [
    "init, close", `Quick, begin fun () ->
      with_pipe ignore
    end;

    "bind", `Quick, begin fun () ->
      with_pipe begin fun pipe ->
        Luv.Pipe.bind pipe filename
        |> check_success "bind";

        Alcotest.(check bool) "created" true (Sys.file_exists filename)
      end
    end;

    "listen, accept", `Quick, begin fun () ->
      let accepted = ref false in
      let connected = ref false in

      with_server_and_client ()
        ~server_logic:
          begin fun server client ->
            Luv.Pipe.getsockname client
            |> check_success_result "getsockname result"
            |> Alcotest.(check string) "getsockname address" filename;
            accepted := true;
            Luv.Handle.close client;
            Luv.Handle.close server
          end
        ~client_logic:
          begin fun client ->
            Luv.Pipe.getpeername client
            |> check_success_result "getpeername result"
            |> Alcotest.(check string) "getpeername address" filename;
            connected := true;
            Luv.Handle.close client
          end;

      Alcotest.(check bool) "accepted" true !accepted;
      Alcotest.(check bool) "connected" true !connected
    end;

    (* TODO read/write test. *)

    (* TODO Test Stream.write2 here. *)

    "chmod, unbound", `Quick, begin fun () ->
      with_pipe begin fun pipe ->
        Luv.Pipe.(chmod pipe Mode.readable)
        |> check_error_code "chmod" Luv.Error.ebadf
      end
    end;

    "chmod", `Quick, begin fun () ->
      with_pipe begin fun pipe ->
        Luv.Pipe.bind pipe filename
        |> check_success "bind";

        Luv.Pipe.(chmod pipe Mode.readable)
        |> check_success "chmod"
      end
    end;
  ]
]
