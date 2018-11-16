open Test_helpers

let with_tcp ?(close = true) f =
  let tcp =
    Luv.TCP.init ()
    |> check_success_result "init"
  in

  f tcp;

  if close then begin
    Luv.Handle.close tcp;
    run ()
  end

let with_server_and_client ~server_logic ~client_logic =
  let address = fresh_address () in

  let server = Luv.TCP.init () |> check_success_result "server init" in
  Luv.TCP.bind server address |> check_success "bind";
  Luv.Stream.listen server begin fun result ->
    check_success "listen" result;
    let client = Luv.TCP.init () |> check_success_result "remote client init" in
    Luv.Stream.accept ~server ~client |> check_success "accept";
    server_logic server client
  end;

  let client = Luv.TCP.init () |> check_success_result "client init" in
  Luv.TCP.connect client address begin fun result ->
    check_success "connect" result;
    client_logic client address
  end;

  run ()

let tests = [
  "tcp", [
    "init, close", `Quick, begin fun () ->
      with_tcp ignore
    end;

    "nodelay", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        Luv.TCP.nodelay tcp true
        |> check_success "nodelay"
      end
    end;

    "keepalive", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        Luv.TCP.keepalive tcp None
        |> check_success "keepalive"
      end
    end;

    "simultaneous_accepts", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        Luv.TCP.simultaneous_accepts tcp true
        |> check_success "simultaneous_accepts"
      end
    end;

    "bind, getsockname", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        let address = fresh_address () in

        Luv.TCP.bind tcp address
        |> check_success "bind";

        Luv.TCP.getsockname tcp
        |> check_success_result "getsockname result"
        |> Luv.Sockaddr.to_string
        |> Alcotest.(check string) "getsockname address"
          (Luv.Sockaddr.to_string address)
      end
    end;

    "connect", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        let finished = ref false in
        let address = fresh_address () in

        Luv.TCP.connect tcp address begin fun result ->
          check_error_code "connect" Luv.Error.econnrefused result;
          finished := true
        end;

        run ();
        Alcotest.(check bool) "finished" true !finished
      end
    end;

    (* Fails with a segfault if the binding doesn't retain a reference to the
       callback. *)
    "gc", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        let finished = ref false in
        let address = fresh_address () in

        Luv.TCP.connect tcp address begin fun _result ->
          finished := true
        end;

        Gc.full_major ();

        run ();
        Alcotest.(check bool) "finished" true !finished
      end
    end;

    "connect, callback leak", `Slow, begin fun () ->
      let address = fresh_address () in

      no_memory_leak ~base_repetitions:1 begin fun _n ->
        with_tcp begin fun tcp ->
          Luv.TCP.connect tcp address (make_callback ());
          run ()
        end
      end
    end;

    "connect, synchronous error", `Quick, begin fun () ->
      let address = fresh_address () in
      let result = ref Luv.Error.success in

      with_tcp begin fun tcp ->
        Luv.TCP.connect tcp address ignore;
        Luv.TCP.connect tcp address begin fun result' ->
          result := result'
        end;

        check_error_code "connect" Luv.Error.ealready !result;
        run ()
      end
    end;

    "connect, synchronous error leak", `Slow, begin fun () ->
      let address = fresh_address () in

      no_memory_leak ~base_repetitions:1 begin fun _n ->
        with_tcp begin fun tcp ->
          Luv.TCP.connect tcp address ignore;
          Luv.TCP.connect tcp address ignore;
          run ()
        end
      end
    end;

    "connect, handle lifetime", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        let address = fresh_address () in
        Luv.TCP.connect tcp address begin fun result ->
          check_error_code "connect" Luv.Error.ecanceled result
        end
      end
    end;

    "listen, accept", `Quick, begin fun () ->
      let accepted = ref false in
      let connected = ref false in

      with_server_and_client
        ~server_logic:
          begin fun server client ->
            accepted := true;
            Luv.Handle.close client;
            Luv.Handle.close server
          end
        ~client_logic:
          begin fun client address ->
            Luv.TCP.getpeername client
            |> check_success_result "getpeername result"
            |> Luv.Sockaddr.to_string
            |> Alcotest.(check string) "getpeername address"
              (Luv.Sockaddr.to_string address);
            connected := true;
            Luv.Handle.close client
          end;

      Alcotest.(check bool) "accepted" true !accepted;
      Alcotest.(check bool) "connected" true !connected
    end;

    "listen: exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        with_server_and_client
          ~server_logic:
            begin fun server client ->
              Luv.Handle.close client;
              Luv.Handle.close server;
              raise Exit
            end
          ~client_logic:(fun client _address -> Luv.Handle.close client)
      end
    end;

    "connect: exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        with_server_and_client
          ~server_logic:
            begin fun server client ->
              Luv.Handle.close client;
              Luv.Handle.close server
            end
          ~client_logic:
            begin fun client _address ->
              Luv.Handle.close client;
              raise Exit
            end
      end
    end;

    "connect, sync exception", `Quick, begin fun () ->
      let address = fresh_address () in

      check_exception Exit begin fun () ->
        with_tcp begin fun tcp ->
          Luv.TCP.connect tcp address ignore;
          Luv.TCP.connect tcp address (fun _result -> raise Exit);
          run ()
        end
      end
    end;

    "read, write", `Quick, begin fun () ->
      let write_finished = ref false in
      let read_finished = ref false in
      let buffer1_finalized = ref false in
      let buffer2_finalized = ref false in
      let buffer3_finalized = ref false in

      with_server_and_client
        ~server_logic:
          begin fun server client ->
            Luv.Stream.read_start client begin fun result ->
              check_success_result "read_start" result
              |> Luv.Bigstring.to_string
              |> Alcotest.(check string) "data" "foo";

              Luv.Handle.close client;
              Luv.Handle.close server;

              read_finished := true
            end
          end
        ~client_logic:
          begin fun client _address ->
            let buffer1 = Luv.Bigstring.from_string "fo" in
            let buffer2 = Luv.Bigstring.from_string "xoy" in
            let buffer3 = Luv.Bigstring.sub buffer2 ~offset:1 ~length:1 in

            Gc.finalise (fun _ -> buffer1_finalized := true) buffer1;
            Gc.finalise (fun _ -> buffer2_finalized := true) buffer2;
            Gc.finalise (fun _ -> buffer3_finalized := true) buffer3;

            Luv.Stream.write client [buffer1; buffer3] begin fun result count ->
              Luv.Handle.close client;
              check_success "write" result;
              Alcotest.(check int) "count" 3 count;
              write_finished := true
            end;

            Alcotest.(check bool) "asynchronous" false !write_finished;
            Gc.full_major ();
            Alcotest.(check bool) "retained" false !buffer1_finalized;
            Alcotest.(check bool) "finalized" true !buffer2_finalized;
            Alcotest.(check bool) "retained" false !buffer3_finalized
          end;

      Alcotest.(check bool) "write finished" true !write_finished;
      Alcotest.(check bool) "read finished" true !read_finished;

      Gc.full_major ();

      Alcotest.(check bool) "finalized" true !buffer1_finalized;
      Alcotest.(check bool) "finalized" true !buffer3_finalized
    end;

    "write: sync error", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        let called = ref false in

        Luv.Stream.write tcp [] begin fun result count ->
          check_error_code "write" Luv.Error.ebadf result;
          Alcotest.(check int) "count" 0 count;
          called := true
        end;

        Alcotest.(check bool) "called" true !called
      end
    end;

    "write: sync error leak", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        no_memory_leak begin fun _ ->
          Luv.Stream.write tcp [] (fun _ -> make_callback ())
        end
      end
    end;

    "read: exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        with_server_and_client
          ~server_logic:
            begin fun server client ->
              Luv.Stream.read_start client begin fun result ->
                ignore (check_success_result "read_start" result);
                Luv.Handle.close client;
                Luv.Handle.close server;
                raise Exit
              end
            end
          ~client_logic:
            begin fun client _address ->
              let buffer = Luv.Bigstring.from_string "f" in
              Luv.Stream.write client [buffer] begin fun result count ->
                check_success "write" result;
                Alcotest.(check int) "count" 1 count;
                Luv.Handle.close client
              end
            end
      end
    end;

    "read: sync exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        with_tcp begin fun tcp ->
          Luv.Stream.read_start tcp (fun _result -> raise Exit)
        end
      end
    end;

    "write: exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        with_server_and_client
          ~server_logic:
            begin fun server client ->
              Luv.Stream.read_start client begin fun result ->
                ignore (check_success_result "read_start" result);
                Luv.Handle.close client;
                Luv.Handle.close server
              end
            end
          ~client_logic:
            begin fun client _address ->
              let buffer = Luv.Bigstring.from_string "f" in
              Luv.Stream.write client [buffer] begin fun result ->
                check_success "write" result;
                Luv.Handle.close client;
                raise Exit
              end
            end
      end
    end;

    "write: sync exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        with_tcp begin fun tcp ->
          Luv.Stream.write tcp [] begin fun result ->
            check_error_code "write" Luv.Error.ebadf result;
            raise Exit
          end
        end
      end
    end;

    "try_write", `Quick, begin fun () ->
      let write_finished = ref false in
      let read_finished = ref false in

      with_server_and_client
        ~server_logic:
          begin fun server client ->
            Luv.Stream.read_start client begin fun result ->
              ignore (check_success_result "read_start" result);
              Luv.Handle.close client;
              Luv.Handle.close server;
              read_finished := true
            end
          end
        ~client_logic:
          begin fun client _address ->
            let buffer1 = Luv.Bigstring.from_string "fo" in
            let buffer2 = Luv.Bigstring.from_string "o" in

            Luv.Stream.try_write client [buffer1; buffer2]
            |> check_success_result "try_write"
            |> Alcotest.(check int) "count" 3;

            Luv.Handle.close client;
            write_finished := true
          end;

      Alcotest.(check bool) "write finished" true !write_finished;
      Alcotest.(check bool) "read finished" true !read_finished
    end;

    "try_write: error", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        Luv.Stream.try_write tcp []
        |> check_error_result "try_write" Luv.Error.ebadf
      end
    end;

    "shutdown", `Quick, begin fun () ->
      let server_finished = ref false in
      let client_finished = ref false in

      with_server_and_client
        ~server_logic:
          begin fun server client ->
            Luv.Stream.shutdown client begin fun result ->
              check_success "server shutdown" result;
              Luv.Handle.close client;
              Luv.Handle.close server;
              server_finished := true
            end
          end
        ~client_logic:
          begin fun client _address ->
            Luv.Stream.shutdown client begin fun result ->
              check_success "client shutdown" result;
              Luv.Handle.close client;
              client_finished := true
            end
          end;

      Alcotest.(check bool) "server finished" true !server_finished;
      Alcotest.(check bool) "client finished" true !client_finished
    end;

    "shutdown: sync error", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        let called = ref false in

        Luv.Stream.shutdown tcp begin fun result ->
          check_error_code "shutdown" Luv.Error.enotconn result;
          called := true
        end;

        Alcotest.(check bool) "called" true !called
      end
    end;

    "shutdown: sync error leak", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        no_memory_leak begin fun _ ->
          Luv.Stream.shutdown tcp (make_callback ())
        end
      end
    end;

    "shutdown: exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        with_server_and_client
          ~server_logic:
            begin fun server client ->
              Luv.Stream.shutdown client begin fun _result ->
                Luv.Handle.close client;
                Luv.Handle.close server;
                raise Exit
              end
            end
          ~client_logic:(fun client _address -> Luv.Handle.close client)
      end
    end;

    "shutdown: sync exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        with_tcp begin fun tcp ->
          Luv.Stream.shutdown tcp (fun _result -> raise Exit)
        end
      end
    end;
  ]
]
