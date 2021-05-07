(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



open Test_helpers

let with_tcp ?(close = true) f =
  let tcp =
    Luv.TCP.init ()
    |> check_success_result "init"
  in

  f tcp;

  if close then begin
    Luv.Handle.close tcp ignore;
    run ()
  end

let with_server_and_client ~server_logic ~client_logic =
  let address = fresh_address () in

  let server = Luv.TCP.init () |> check_success_result "server init" in
  Luv.TCP.bind server address |> check_success_result "bind";
  let sockaddr = Luv.TCP.getsockname server |> check_success_result "getsockname" in
  if Luv.Sockaddr.to_string sockaddr = None then failwith "Luv.Sockaddr.to_string returned None";
  if Luv.Sockaddr.port sockaddr = None then failwith "Luv.Sockaddr.port returned None";
  Luv.Stream.listen server begin fun result ->
    check_success_result "listen" result;
    let client = Luv.TCP.init () |> check_success_result "remote client init" in
    Luv.Stream.accept ~server ~client |> check_success_result "accept";
    server_logic server client
  end;

  let client = Luv.TCP.init () |> check_success_result "client init" in
  Luv.TCP.connect client address begin fun result ->
    check_success_result "connect" result;
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
        |> check_success_result "nodelay"
      end
    end;

    "keepalive", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        Luv.TCP.keepalive tcp None
        |> check_success_result "keepalive"
      end
    end;

    "simultaneous_accepts", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        Luv.TCP.simultaneous_accepts tcp true
        |> check_success_result "simultaneous_accepts"
      end
    end;

    "bind, getsockname", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        let address = fresh_address () in

        Luv.TCP.bind tcp address
        |> check_success_result "bind";

        Luv.TCP.getsockname tcp
        |> check_success_result "getsockname result"
        |> Luv.Sockaddr.to_string
        |> Alcotest.(check (option string)) "getsockname address"
          (Luv.Sockaddr.to_string address)
      end
    end;

    "connect", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        let finished = ref false in
        let address = fresh_address () in

        Luv.TCP.connect tcp address begin fun result ->
          check_error_result "connect" `ECONNREFUSED result;
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
      let result = ref (Result.Ok ()) in

      with_tcp begin fun tcp ->
        Luv.TCP.connect tcp address ignore;
        Luv.TCP.connect tcp address begin fun result' ->
          result := result'
        end;

        check_error_results "connect" [`EALREADY; `EINVAL] !result;
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
          check_error_result "connect" `ECANCELED result
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
            Luv.Handle.close client ignore;
            Luv.Handle.close server ignore
          end
        ~client_logic:
          begin fun client address ->
            Luv.TCP.getpeername client
            |> check_success_result "getpeername result"
            |> Luv.Sockaddr.to_string
            |> Alcotest.(check (option string)) "getpeername address"
              (Luv.Sockaddr.to_string address);
            connected := true;
            Luv.Handle.close client ignore
          end;

      Alcotest.(check bool) "accepted" true !accepted;
      Alcotest.(check bool) "connected" true !connected
    end;

    "listen: exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        with_server_and_client
          ~server_logic:
            begin fun server client ->
              Luv.Handle.close client ignore;
              Luv.Handle.close server ignore;
              raise Exit
            end
          ~client_logic:(fun client _address -> Luv.Handle.close client ignore)
      end
    end;

    "connect: exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        with_server_and_client
          ~server_logic:
            begin fun server client ->
              Luv.Handle.close client ignore;
              Luv.Handle.close server ignore
            end
          ~client_logic:
            begin fun client _address ->
              Luv.Handle.close client ignore;
              raise Exit
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
              |> Luv.Buffer.to_string
              |> Alcotest.(check string) "data" "foo";

              Luv.Handle.close client ignore;
              Luv.Handle.close server ignore;

              read_finished := true
            end
          end
        ~client_logic:
          begin fun client _address ->
            let buffer1 = Luv.Buffer.from_string "fo" in
            let buffer2 = Luv.Buffer.from_string "xoy" in
            let buffer3 = Luv.Buffer.sub buffer2 ~offset:1 ~length:1 in

            Gc.finalise (fun _ -> buffer1_finalized := true) buffer1;
            Gc.finalise (fun _ -> buffer2_finalized := true) buffer2;
            Gc.finalise (fun _ -> buffer3_finalized := true) buffer3;

            Luv.Stream.write client [buffer1; buffer3] begin fun result count ->
              Luv.Handle.close client ignore;
              check_success_result "write" result;
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

    "eof", `Quick, begin fun () ->
      let read_finished = ref false in

      with_server_and_client
        ~server_logic:
          begin fun server client ->
            Luv.Stream.read_start client begin fun result ->
              check_error_result "read_start" `EOF result;
              Luv.Handle.close client ignore;
              Luv.Handle.close server ignore;
              read_finished := true
            end
          end
        ~client_logic:
          begin fun client _address ->
            Luv.Handle.close client ignore
          end;

      Alcotest.(check bool) "read finished" true !read_finished;
    end;

    "write: sync error", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        let called = ref false in

        Luv.Stream.write tcp [Luv.Buffer.from_string ""]
            begin fun result count ->
          check_error_results "write" [`EBADF; `EPIPE] result;
          Alcotest.(check int) "count" 0 count;
          called := true
        end;

        Alcotest.(check bool) "called" true !called
      end
    end;

    "write: sync error leak", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        no_memory_leak begin fun _ ->
          Luv.Stream.write tcp [Luv.Buffer.from_string ""] (fun _ ->
            make_callback ())
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
                Luv.Handle.close client ignore;
                Luv.Handle.close server ignore;
                raise Exit
              end
            end
          ~client_logic:
            begin fun client _address ->
              let buffer = Luv.Buffer.from_string "f" in
              Luv.Stream.write client [buffer] begin fun result count ->
                check_success_result "write" result;
                Alcotest.(check int) "count" 1 count;
                Luv.Handle.close client ignore
              end
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
                Luv.Handle.close client ignore;
                Luv.Handle.close server ignore
              end
            end
          ~client_logic:
            begin fun client _address ->
              let buffer = Luv.Buffer.from_string "f" in
              Luv.Stream.write client [buffer] begin fun result ->
                check_success_result "write" result;
                Luv.Handle.close client ignore;
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
              Luv.Handle.close client ignore;
              Luv.Handle.close server ignore;
              read_finished := true
            end
          end
        ~client_logic:
          begin fun client _address ->
            let buffer1 = Luv.Buffer.from_string "fo" in
            let buffer2 = Luv.Buffer.from_string "o" in

            Luv.Stream.try_write client [buffer1; buffer2]
            |> check_success_result "try_write"
            |> Alcotest.(check int) "count" 3;

            Luv.Handle.close client ignore;
            write_finished := true
          end;

      Alcotest.(check bool) "write finished" true !write_finished;
      Alcotest.(check bool) "read finished" true !read_finished
    end;

    "try_write: error", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        Luv.Stream.try_write tcp [Luv.Buffer.from_string ""]
        |> check_error_results "try_write" [`EBADF; `EPIPE]
      end
    end;

    "shutdown", `Quick, begin fun () ->
      let server_finished = ref false in
      let client_finished = ref false in

      with_server_and_client
        ~server_logic:
          begin fun server client ->
            Luv.Stream.shutdown client begin fun result ->
              check_success_result "server shutdown" result;
              Luv.Handle.close client ignore;
              Luv.Handle.close server ignore;
              server_finished := true
            end
          end
        ~client_logic:
          begin fun client _address ->
            Luv.Stream.shutdown client begin fun result ->
              check_success_result "client shutdown" result;
              Luv.Handle.close client ignore;
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
          check_error_result "shutdown" `ENOTCONN result;
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
                Luv.Handle.close client ignore;
                Luv.Handle.close server ignore;
                raise Exit
              end
            end
          ~client_logic:(fun client _address -> Luv.Handle.close client ignore)
      end
    end;

    "close_reset: sync error", `Quick, begin fun () ->
      let called = ref false in

      with_tcp begin fun tcp ->
        Luv.TCP.close_reset tcp begin fun result ->
          check_error_results "close_reset" [`EBADF; `ENOTSOCK] result;
          called := true
        end
      end;

      Alcotest.(check bool) "called" true !called
    end;

    "close_reset", `Quick, begin fun () ->
      let called = ref false in
      let address = fresh_address () in

      let server = Luv.TCP.init () |> check_success_result "server init" in
      Luv.TCP.bind server address |> check_success_result "bind";
      Luv.Stream.listen server begin fun result ->
        check_success_result "listen" result;
        let client =
          Luv.TCP.init () |> check_success_result "remote client init" in
        Luv.Stream.accept ~server ~client |> check_success_result "accept";
        Luv.TCP.close_reset client begin fun result ->
          check_success_result "close_reset" result;
          Luv.Handle.close server ignore;
          called := true
        end
      end;

      let client = Luv.TCP.init () |> check_success_result "client init" in
      Luv.TCP.connect client address begin fun _result ->
        Luv.Handle.close client ignore
      end;

      run ();

      Alcotest.(check bool) "called" true !called
    end;

    (* This is a compilation test. If the type constraints in handle.mli are
       wrong, there will be a type error in this test. *)
    "handle functions", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        ignore @@ Luv.Handle.send_buffer_size tcp;
        ignore @@ Luv.Handle.recv_buffer_size tcp;
        ignore @@ Luv.Handle.set_send_buffer_size tcp 4096;
        ignore @@ Luv.Handle.set_recv_buffer_size tcp 4096;
        ignore @@ Luv.Handle.fileno tcp
      end
    end;

    "socketpair", `Quick, begin fun () ->
      let wrap os_socket =
        let socket = Luv.TCP.init () |> check_success_result "init" in
        Luv.TCP.open_ socket os_socket |> check_success_result "open_";
        socket
      in
      let fst_socket, snd_socket =
        Luv.TCP.socketpair `STREAM 0 |> check_success_result "socketpair" in
      let fst_socket = wrap fst_socket in
      let snd_socket = wrap snd_socket in

      Luv.Stream.write fst_socket [Luv.Buffer.from_string "x"] (fun _ _ -> ());
      Luv.Handle.close fst_socket ignore;

      let read = ref false in

      Luv.Stream.read_start snd_socket begin fun result ->
        check_success_result "read_start" result
        |> Luv.Buffer.to_string
        |> Alcotest.(check string) "byte" "x";
        read := true;
        Luv.Handle.close snd_socket ignore
      end;

      run ();

      Alcotest.(check bool) "read" true !read
    end;
  ]
]
