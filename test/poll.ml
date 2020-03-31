(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



open Test_helpers

let with_test_fd f =
  let address = fresh_address () in

  let server = Luv.TCP.init () |> check_success_result "server init" in
  let remote_client =
    Luv.TCP.init () |> check_success_result "remote client init" in
  Luv.TCP.bind server address |> check_success_result "bind";
  Luv.Stream.listen server begin fun result ->
    check_success_result "listen" result;
    Luv.Stream.accept ~server ~client:remote_client
    |> check_success_result "accept"
  end;

  let client = Luv.TCP.init () |> check_success_result "client init" in
  Luv.TCP.connect client address begin fun result ->
    check_success_result "connect" result;
    let os_socket = Luv.Handle.fileno client |> check_success_result "fileno" in
    let os_socket : Luv.Os_fd.Socket.t = Obj.magic os_socket in
    f (os_socket);
    Luv.Handle.close client ignore;
    Luv.Handle.close remote_client ignore
  end

let with_poll f =
  with_test_fd begin fun socket ->
    let poll =
      Luv.Poll.init_socket socket
      |> check_success_result "init_socket"
    in

    f poll;

    Luv.Handle.close poll ignore;
    run ()
  end

let tests = [
  "poll", [
    "init, close", `Quick, begin fun () ->
      with_poll ignore
    end;

    "start, stop", `Quick, begin fun () ->
      with_poll begin fun poll ->
        let called = ref false in

        Luv.Poll.start poll [`WRITABLE] begin fun result ->
          check_success_result "result" result
          |> List.mem `WRITABLE
          |> Alcotest.(check bool) "writable" true;

          Luv.Poll.stop poll
          |> check_success_result "stop";

          called := true
        end;

        run ();

        Alcotest.(check bool) "called" true !called
      end
    end;

    "exception", `Quick, begin fun () ->
      with_poll begin fun poll ->
        check_exception Exit begin fun () ->
          Luv.Poll.start poll [`WRITABLE] begin fun _ ->
            Luv.Poll.stop poll |> ignore;
            raise Exit
          end;

          run ()
        end
      end
    end;

    (* This is a compilation test. If the type constraints in handle.mli are
       wrong, there will be a type error in this test. *)
    "handle functions", `Quick, begin fun () ->
      with_poll begin fun poll ->
        ignore @@ Luv.Handle.fileno poll
      end
    end;
  ]
]
