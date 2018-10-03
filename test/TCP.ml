open Test_helpers

let with_tcp f =
  let tcp =
    Luv.TCP.init ()
    |> check_success_result "init"
  in

  f tcp;

  (* TODO This is incorrect when closing asynchronously. *)
  (* TODO Review all such with... functions in all test cases. *)
  Luv.Handle.close tcp;
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

    (* "bind, getsockname", `Quick, begin fun () -> *)
    "bind", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        let address = Unix.(ADDR_INET (inet_addr_loopback, port ())) in

        Luv.TCP.bind tcp address
        |> check_success "bind";

        (* TODO Test getsockname. *)
        (* Luv.TCP.getsockname tcp
        |> check_success_result "getsockname"
        |> fun address' ->
          if not (address' = address) then
            Alcotest.fail "address" *)
      end
    end;

    "connect", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        let finished = ref false in

        let address = Unix.(ADDR_INET (inet_addr_loopback, port ())) in

        let request = Luv.Stream.Connect_request.make () in
        Luv.TCP.connect ~request tcp address ~callback:(fun request' result ->
          if not (request' == request) then
            Alcotest.fail "same request";
          check_error_code "result" Luv.Error.econnrefused result;
          finished := true)
        |> check_success "connect";

        run ();
        Alcotest.(check bool) "finished" true !finished
      end
    end;

    (* Fails with a segfault if the binding doesn't retain a reference to the
       callback. *)
    "gc", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        let finished = ref false in

        let address = Unix.(ADDR_INET (inet_addr_loopback, port ())) in

        Luv.TCP.connect tcp address ~callback:(fun _ _ ->
          finished := true)
        |> check_success "connect";

        Gc.full_major ();

        run ();
        Alcotest.(check bool) "finished" true !finished
      end
    end;

    "connect, callback leak", `Quick, begin fun () ->
      let address = Unix.(ADDR_INET (inet_addr_loopback, port ())) in

      no_memory_leak ~base_repetitions:1 begin fun _n ->
        with_tcp begin fun tcp ->
          Luv.TCP.connect tcp address ~callback:(fun _ ->
            make_callback ())
          |> check_success "connect";
          run ()
        end
      end
    end;

    "connect, handle lifetime", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        let address = Unix.(ADDR_INET (inet_addr_loopback, port ())) in
        Luv.TCP.connect tcp address ~callback:(fun _ result ->
          check_error_code "result" Luv.Error.ecanceled result)
        |> check_success "connect"
      end
    end;

    (* TODO Obj.magic in this test can be removed with a handle upcast. *)
    "connect, handle identity", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        let address = Unix.(ADDR_INET (inet_addr_loopback, port ())) in
        Luv.TCP.connect tcp address ~callback:(fun request _ ->
          let handle : [ `Base ] Luv.Stream.t =
            Luv.Stream.Connect_request.get_handle request in
          let handle : Luv.TCP.t = Obj.magic handle in
          if not (handle == tcp) then
            Alcotest.fail "handle")
        |> check_success "connect"
      end
    end;

    (* "connect, request reuse", `Quick, begin fun () ->
      with_tcp begin fun tcp ->
        let address = Unix.(ADDR_INET (inet_addr_loopback, port ())) in
        let request = Luv.Stream.Connect_request.make () in
        Luv.TCP.connect ~request tcp address ~callback:(fun _ _ -> ())
        |> check_success "connect";

        run ();

        Alcotest.check_raises
          "second connect"
          Luv.Request.Request_object_reused_this_is_a_programming_error
          (fun () ->
            Luv.TCP.connect ~request tcp address ~callback:(fun _ _ -> ())
            |> ignore)
      end
    end; *)

    "listen, accept", `Quick, begin fun () ->
      let connected = ref false in

      let address = Unix.(ADDR_INET (inet_addr_loopback, port ())) in

      with_tcp begin fun server ->
        Luv.TCP.bind server address
        |> check_success "bind";

        Luv.Stream.listen ~backlog:5 server ~callback:(fun server' result ->
          if not (server' == server) then
            Alcotest.fail "server";
          check_success "server result" result;
          let remote_client =
            Luv.Stream.accept server
            |> check_success_result "accept"
          in
          connected := true;
          Luv.Handle.close remote_client;
          Luv.Handle.close server)
        |> check_success "listen";

        with_tcp begin fun client ->
          Luv.TCP.connect client address ~callback:(fun _ result ->
            check_success "client result" result)
          |> check_success "connect";

          run ();
          Alcotest.(check bool) "connected" true !connected
        end
      end
    end;

    "read, write", `Quick, begin fun () ->
      let write_finished = ref false in
      let read_finished = ref false in

      let address = Unix.(ADDR_INET (inet_addr_loopback, port ())) in

      with_tcp begin fun server ->
        Luv.TCP.bind server address
        |> check_success "bind";

        (* TODO Try @@ for this kind of thing. *)
        check_success "listen" @@
        Luv.Stream.listen ~backlog:5 server ~callback:begin fun _ result ->
          check_success "server result" result;

          let remote_client =
            Luv.Stream.accept server
            |> check_success_result "accept"
          in

          check_success "read_start" @@
          Luv.Stream.read_start remote_client
              ~allocate:(fun _ -> Luv.Bigstring.create)
              ~callback:begin fun remote_client' result ->
            if not (remote_client' == remote_client) then
              Alcotest.fail "remote_client";

            begin match result with
            | Error _ ->
              Alcotest.fail "read result"
            | Ok (buffer, length) ->
              Alcotest.(check int) "length" 3 length;
              Alcotest.(check char) "byte 0" 'f' (Bigarray.Array1.get buffer 0);
              Alcotest.(check char) "byte 1" 'o' (Bigarray.Array1.get buffer 1);
              Alcotest.(check char) "byte 2" 'o' (Bigarray.Array1.get buffer 2);
            end;

            Luv.Handle.close remote_client';
            Luv.Handle.close server;

            read_finished := true
          end
        end;

        with_tcp begin fun client ->
          check_success "connect" @@
          Luv.TCP.connect client address ~callback:begin fun _ result ->
            check_success "client result" result;

            let buffer1 = Bigarray.(Array1.create Char C_layout 2) in
            let buffer2 = Bigarray.(Array1.create Char C_layout 1) in

            Bigarray.Array1.set buffer1 0 'f';
            Bigarray.Array1.set buffer1 1 'o';
            Bigarray.Array1.set buffer2 0 'o';

            Luv.Stream.write client [buffer1; buffer2]
                ~callback:(fun _ result ->
              check_success "write result" result;
              write_finished := true)
            |> check_success "write"
          end;

          run ();

          Alcotest.(check bool) "write_finished" true !write_finished;
          Alcotest.(check bool) "read_finished" true !read_finished
        end
      end
    end;
  ]
]

(* TODO Basic stream and request tests? *)
