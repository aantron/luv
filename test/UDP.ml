(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



open Test_helpers

let with_udp f =
  let udp = Luv.UDP.init () |> check_success_result "init" in

  f udp;

  Luv.Handle.close udp ignore;
  run ()

let with_sender_and_receiver ~receiver_logic ~sender_logic =
  let address = fresh_address () in

  let receiver = Luv.UDP.init () |> check_success_result "receiver init" in
  Luv.UDP.bind receiver address |> check_success_result "bind";
  let sockaddr = Luv.UDP.getsockname receiver |> check_success_result "getsockname" in
  if Luv.Sockaddr.to_string sockaddr = None then failwith "Luv.Sockaddr.to_string returned None";
  if Luv.Sockaddr.port sockaddr = None then failwith "Luv.Sockaddr.port returned None";

  let sender = Luv.UDP.init () |> check_success_result "sender init" in

  receiver_logic receiver;
  sender_logic sender address;

  run ()

let expect receiver expected_data k =
  Luv.UDP.recv_start receiver begin fun result ->
    let buffer, _peer_address, flags =
      check_success_result "recv_start" result in
    if flags <> [] then
      Alcotest.fail "unexpected partial recv";
    Alcotest.(check int) "length"
      (String.length expected_data) (Luv.Buffer.size buffer);
    Alcotest.(check string) "data" expected_data Luv.Buffer.(to_string buffer);
    Luv.UDP.recv_stop receiver |> check_success_result "recv_stop";
    k ()
  end

let tests = [
  "udp", [
    "init, close", `Quick, begin fun () ->
      with_udp ignore
    end;

    "bind, getsockname", `Quick, begin fun () ->
      with_udp begin fun udp ->
        let address = fresh_address () in

        Luv.UDP.bind udp address |> check_success_result "bind";
        Luv.UDP.getsockname udp
        |> check_success_result "getsockname"
        |> Luv.Sockaddr.to_string
        |> Alcotest.(check (option string)) "address"
          (Luv.Sockaddr.to_string address)
      end
    end;

    "send, recv", `Quick, begin fun () ->
      let receiver_finished = ref false in
      let sender_finished = ref false in

      with_sender_and_receiver
        ~receiver_logic:
          begin fun receiver ->
            expect receiver "foo" begin fun () ->
              Luv.Handle.close receiver ignore;
              receiver_finished := true
            end
          end
        ~sender_logic:
          begin fun sender address ->
            let buffer = Luv.Buffer.from_string "foo" in
            Luv.UDP.send sender [buffer] address begin fun result ->
              check_success_result "send" result;
              Luv.Handle.close sender ignore;
              sender_finished := true
            end
          end;

      Alcotest.(check bool) "receiver finished" true !receiver_finished;
      Alcotest.(check bool) "sender finished" true !sender_finished
    end;

    "try_send", `Quick, begin fun () ->
      let receiver_finished = ref false in
      let sender_finished = ref false in

      with_sender_and_receiver
        ~receiver_logic:
          begin fun receiver ->
            expect receiver "foo" begin fun () ->
              Luv.Handle.close receiver ignore;
              receiver_finished := true
            end
          end
        ~sender_logic:
          begin fun sender address ->
            Luv.UDP.try_send sender [Luv.Buffer.from_string "foo"] address
            |> check_success_result "try_send";
            Luv.Handle.close sender ignore;
            sender_finished := true
          end;

      Alcotest.(check bool) "receiver finished" true !receiver_finished;
      Alcotest.(check bool) "sender finished" true !sender_finished
    end;

    "send: exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        with_sender_and_receiver
          ~receiver_logic:
            begin fun receiver ->
              expect receiver "foo" (fun () -> Luv.Handle.close receiver ignore)
            end
          ~sender_logic:
            begin fun sender address ->
              let buffer = Luv.Buffer.from_string "foo" in
              Luv.UDP.send sender [buffer] address begin fun result ->
                check_success_result "send" result;
                Luv.Handle.close sender ignore;
                raise Exit
              end
            end
      end
    end;

    "recv: exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        with_sender_and_receiver
          ~receiver_logic:
            begin fun receiver ->
              expect receiver "foo" begin fun () ->
                Luv.Handle.close receiver ignore;
                raise Exit
              end
            end
          ~sender_logic:
            begin fun sender address ->
              Luv.UDP.try_send sender [Luv.Buffer.from_string "foo"] address
              |> check_success_result "try_send";
              Luv.Handle.close sender ignore
            end
      end
    end;

    "empty datagram", `Quick, begin fun () ->
      with_sender_and_receiver
        ~receiver_logic:
          begin fun receiver ->
            expect receiver "" begin fun () ->
              Luv.Handle.close receiver ignore
            end
          end
        ~sender_logic:
          begin fun sender address ->
            Luv.UDP.try_send sender [Luv.Buffer.from_string ""] address
            |> check_success_result "try_send";
            Luv.Handle.close sender ignore
          end
    end;

    "multicast", `Quick, begin fun () ->
      (* This test is not working in Travis for reasons not yet known to me. *)
      if in_travis then
        ()
      else begin
        let group = "239.0.0.128" in

        let receiver_finished = ref false in
        let sender_finished = ref false in

        with_sender_and_receiver
          ~receiver_logic:
            begin fun receiver ->
              Luv.UDP.set_membership
                receiver ~group ~interface:"127.0.0.1" `JOIN_GROUP
              |> check_success_result "set_membership 1";

              expect receiver "foo" begin fun () ->
                Luv.Handle.close receiver ignore;
                receiver_finished := true
              end
            end
          ~sender_logic:
            begin fun sender address ->
              let port =
                match Luv.Sockaddr.port address with
                | Some port -> port
                | None -> Alcotest.fail "port"
              in
              let address =
                Luv.Sockaddr.ipv4 group port
                |> check_success_result "group address"
              in
              Luv.UDP.try_send sender [Luv.Buffer.from_string "foo"] address
              |> check_success_result "try_send";
              Luv.Handle.close sender ignore;
              sender_finished := true
            end;

        Alcotest.(check bool) "receiver finished" true !receiver_finished;
        Alcotest.(check bool) "sender finished" true !sender_finished
      end
    end;

    (* This is a compilation test. If the type constraints in handle.mli are
       wrong, there will be a type error in this test. *)
    "handle functions", `Quick, begin fun () ->
      with_udp begin fun udp ->
        ignore @@ Luv.Handle.send_buffer_size udp;
        ignore @@ Luv.Handle.recv_buffer_size udp;
        ignore @@ Luv.Handle.set_send_buffer_size udp 4096;
        ignore @@ Luv.Handle.set_recv_buffer_size udp 4096;
        ignore @@ Luv.Handle.fileno udp
      end
    end;

    "connect, getpeername", `Quick, begin fun () ->
      with_udp begin fun udp ->
        Luv.UDP.bind udp (fresh_address ()) |> check_success_result "bind";

        Luv.UDP.Connected.getpeername udp
        |> check_error_result "getpeername, initial" `ENOTCONN;

        let remote = fresh_address () in

        Luv.UDP.Connected.connect udp remote |> check_success_result "connect";
        Luv.UDP.Connected.getpeername udp
        |> check_success_result "getpeername, connected"
        |> Luv.Sockaddr.to_string
        |> Alcotest.(check (option string)) "address"
          (Luv.Sockaddr.to_string remote);

        Luv.UDP.Connected.disconnect udp |> check_success_result "disconnect";

        Luv.UDP.Connected.getpeername udp
        |> check_error_result "getpeername, disconnected" `ENOTCONN
      end
    end;

    "double connect", `Quick, begin fun () ->
      with_udp begin fun udp ->
        Luv.UDP.bind udp (fresh_address ()) |> check_success_result "bind";

        let remote = fresh_address () in
        Luv.UDP.Connected.connect udp remote
        |> check_success_result "first connect";
        Luv.UDP.Connected.connect udp remote
        |> check_error_result "second connect" `EISCONN;
      end
    end;

    "initial disconnect", `Quick, begin fun () ->
      with_udp begin fun udp ->
        Luv.UDP.bind udp (fresh_address ()) |> check_success_result "bind";
        Luv.UDP.Connected.disconnect udp
        |> check_error_result "disconnect" `ENOTCONN
      end
    end;

    "connected, send", `Quick, begin fun () ->
      let receiver_finished = ref false in
      let sender_finished = ref false in

      with_sender_and_receiver
        ~receiver_logic:
          begin fun receiver ->
            expect receiver "foo" begin fun () ->
              Luv.Handle.close receiver ignore;
              receiver_finished := true
            end
          end
        ~sender_logic:
          begin fun sender address ->
            Luv.UDP.Connected.connect sender address
            |> check_success_result "connect";
            Luv.UDP.Connected.send sender [Luv.Buffer.from_string "foo"]
                begin fun result ->
              check_success_result "send" result;
              Luv.Handle.close sender ignore;
              sender_finished := true
            end
          end;

      Alcotest.(check bool) "receiver finished" true !receiver_finished;
      Alcotest.(check bool) "sender finished" true !sender_finished
    end;

    "try_send", `Quick, begin fun () ->
      let receiver_finished = ref false in
      let sender_finished = ref false in

      with_sender_and_receiver
        ~receiver_logic:
          begin fun receiver ->
            expect receiver "foo" begin fun () ->
              Luv.Handle.close receiver ignore;
              receiver_finished := true
            end
          end
        ~sender_logic:
          begin fun sender address ->
            Luv.UDP.Connected.connect sender address
            |> check_success_result "connect";
            Luv.UDP.Connected.try_send sender [Luv.Buffer.from_string "foo"]
            |> check_success_result "try_send";
            Luv.Handle.close sender ignore;
            sender_finished := true
          end;

      Alcotest.(check bool) "receiver finished" true !receiver_finished;
      Alcotest.(check bool) "sender finished" true !sender_finished
    end;
  ]
]
