(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



open Test_helpers

let filename =
  if not Sys.win32 then
    "pipe"
  else
    "\\\\.\\pipe\\pipe"

let with_pipe f =
  let pipe =
    Luv.Pipe.init ()
    |> check_success_result "init"
  in

  f pipe;

  Luv.Handle.close pipe ignore;
  run ();

  Alcotest.(check bool) "file deleted" false (Sys.file_exists filename)

let with_server_and_client ?for_handle_passing () ~server_logic ~client_logic =
  let server =
    Luv.Pipe.init ?for_handle_passing ()
    |> check_success_result "server init"
  in
  Luv.Pipe.bind server filename |> check_success_result "bind";
  Luv.Stream.listen server begin fun result ->
    check_success_result "listen" result;
    let client =
      Luv.Pipe.init ?for_handle_passing ()
      |> check_success_result "remote client init"
    in
    Luv.Stream.accept ~server ~client |> check_success_result "accept";
    server_logic server client
  end;

  let client =
    Luv.Pipe.init ?for_handle_passing ()
    |> check_success_result "client init"
  in
  Luv.Pipe.connect client filename begin fun result ->
    check_success_result "connect" result;
    client_logic client
  end;

  run ();

  Alcotest.(check bool) "file deleted" false (Sys.file_exists filename)

(* Until https://github.com/libuv/libuv/pull/1498. This implementation will not
   work on Windows. One can be provided, but hopefully the PR lands first. *)
let unix_fd_to_file : Unix.file_descr -> Luv.File.t =
  Obj.magic

let tests = [
  "pipe", [
    "init, close", `Quick, begin fun () ->
      with_pipe ignore
    end;

    "pipe", `Quick, begin fun () ->
      let wrap file =
        let pipe = Luv.Pipe.init () |> check_success_result "init" in
        Luv.Pipe.open_ pipe file |> check_success_result "open_";
        pipe
      in
      let read_file, write_file =
        Luv.Pipe.pipe () |> check_success_result "pipe" in
      let read_pipe = wrap read_file in
      let write_pipe = wrap write_file in

      Luv.Stream.write write_pipe [Luv.Buffer.from_string "x"] (fun _ _ -> ());
      Luv.Handle.close write_pipe ignore;

      let read = ref false in

      Luv.Stream.read_start read_pipe begin fun result ->
        check_success_result "read_start" result
        |> Luv.Buffer.to_string
        |> Alcotest.(check string) "byte" "x";
        read := true;
        Luv.Handle.close read_pipe ignore
      end;

      run ();

      Alcotest.(check bool) "read" true !read
    end;

    "bind", `Quick, begin fun () ->
      with_pipe begin fun pipe ->
        Luv.Pipe.bind pipe filename
        |> check_success_result "bind";

        Alcotest.(check bool) "created" true (Sys.file_exists filename)
      end
    end;

    "listen, accept", `Quick, begin fun () ->
      let accepted = ref false in
      let connected = ref false in

      (* On macOS, getpeername fails with EINVAL if the server closes the pipe
         first. So, defer closing of handles until both the server and the
         client have executed their main test logic. *)
      let server_ran = event () in
      let client_ran = event () in

      with_server_and_client ()
        ~server_logic:
          begin fun server client ->
            Luv.Pipe.getsockname client
            |> check_success_result "getsockname result"
            |> fun name ->
              if not @@ List.mem name [filename; ""] then
                Alcotest.failf "getpeername address: %s" name;
            accepted := true;
            proceed server_ran;
            defer client_ran begin fun () ->
              Luv.Handle.close client ignore;
              Luv.Handle.close server ignore
            end
          end
        ~client_logic:
          begin fun client ->
            Luv.Pipe.getpeername client
            |> check_success_result "getpeername result"
            |> fun name ->
              if not @@ List.mem name [filename; "\\\\?\\pipe\\pipe"] then
                Alcotest.failf "getpeername address: %s" name;
            connected := true;
            proceed client_ran;
            defer server_ran (fun () -> Luv.Handle.close client ignore)
          end;

      Alcotest.(check bool) "accepted" true !accepted;
      Alcotest.(check bool) "connected" true !connected
    end;

    "connect: exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        with_server_and_client ()
          ~server_logic:
            begin fun server client ->
              Luv.Handle.close client ignore;
              Luv.Handle.close server ignore
            end
          ~client_logic:
            begin fun client ->
              Luv.Handle.close client ignore;
              raise Exit
            end
      end
    end;

    "read, write", `Quick, begin fun () ->
      let write_finished = ref false in
      let read_finished = ref false in

      with_server_and_client ()
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
          begin fun client ->
            let buffer1 = Luv.Buffer.from_string "fo" in
            let buffer2 = Luv.Buffer.from_string "o" in

            Luv.Stream.write client [buffer1; buffer2] begin fun result count ->
              check_success_result "write" result;
              Alcotest.(check int) "count" 3 count;
              Luv.Handle.close client ignore;
              write_finished := true
            end
          end;

      Alcotest.(check bool) "write finished" true !write_finished;
      Alcotest.(check bool) "read finished" true !read_finished
    end;

    "open_, receive_handle, write2", `Quick, begin fun () ->
      let wrap ~for_handle_passing fd =
        let pipe =
          Luv.Pipe.init ~for_handle_passing () |> check_success_result "init" in
        Luv.Pipe.open_ pipe (unix_fd_to_file fd)
        |> check_success_result "open_";
        pipe
      in

      let ipc_1, ipc_2 = Unix.(socketpair PF_UNIX SOCK_STREAM) 0 in
      let ipc_1 = wrap ~for_handle_passing:true ipc_1 in
      let ipc_2 = wrap ~for_handle_passing:true ipc_2 in

      let passed_1, passed_2 = Unix.(socketpair PF_UNIX SOCK_STREAM) 0 in
      let passed_1 = wrap ~for_handle_passing:false passed_1 in
      let passed_2 = wrap ~for_handle_passing:false passed_2 in

      Luv.Stream.read_start ipc_1 begin fun result ->
        Luv.Stream.read_stop ipc_1 |> check_success_result "read_stop";

        check_success_result "read_start" result
        |> Luv.Buffer.size
        |> Alcotest.(check int) "read byte count" 1;

        begin match Luv.Pipe.receive_handle ipc_1 with
        | `Pipe receive ->
          let received =
            Luv.Pipe.init () |> check_success_result "init received" in
          receive received |> check_success_result "handle accept";
          let buffer = Luv.Buffer.from_string "x" in
          Luv.Stream.try_write received [buffer]
          |> check_success_result "try_write"
          |> Alcotest.(check int) "write byte count" 1;
          Luv.Handle.close received ignore
        | `TCP _ ->
          ignore (Alcotest.fail "expected a pipe, got a TCP handle")
        | `None ->
          ignore (Alcotest.fail "expected a pipe, got nothing")
        end
      end;

      let buffer = Luv.Buffer.create 1 in
      Luv.Stream.write2 ipc_2 [buffer] ~send_handle:passed_1
          begin fun result count ->

        check_success_result "write2" result;
        Alcotest.(check int) "count" 1 count;
      end;

      let did_read = ref false in

      Luv.Stream.read_start passed_2 begin fun result ->
        Luv.Stream.read_stop passed_2 |> check_success_result "read_stop";
        check_success_result "read_start" result
        |> Luv.Buffer.to_string
        |> Alcotest.(check string) "data" "x";
        did_read := true
      end;

      run ();

      Luv.Handle.close ipc_1 ignore;
      Luv.Handle.close ipc_2 ignore;
      Luv.Handle.close passed_1 ignore;
      Luv.Handle.close passed_2 ignore;

      run ();

      Alcotest.(check bool) "did read" true !did_read
    end;

    "chmod, unbound", `Quick, begin fun () ->
      with_pipe begin fun pipe ->
        Luv.Pipe.chmod pipe [`READABLE]
        |> check_error_result "chmod" `EBADF
      end
    end;

    "chmod", `Quick, begin fun () ->
      with_pipe begin fun pipe ->
        Luv.Pipe.bind pipe filename
        |> check_success_result "bind";

        Luv.Pipe.chmod pipe [`READABLE]
        |> check_success_result "chmod"
      end
    end;

    (* This is a compilation test. If the type constraints in handle.mli are
       wrong, there will be a type error in this test. *)
    "handle functions", `Quick, begin fun () ->
      with_pipe begin fun pipe ->
        ignore @@ Luv.Handle.send_buffer_size pipe;
        ignore @@ Luv.Handle.recv_buffer_size pipe;
        ignore @@ Luv.Handle.set_send_buffer_size pipe 4096;
        ignore @@ Luv.Handle.set_recv_buffer_size pipe 4096;
        ignore @@ Luv.Handle.fileno pipe
      end
    end;
  ]
]
