(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



open Test_helpers

let with_signal f =
  let signal =
    Luv.Signal.init ()
    |> check_success_result "init"
  in

  f signal;

  Luv.Handle.close signal ignore;
  run ()

let send_signal () =
  Unix.kill (Unix.getpid ()) Sys.sighup

let tests = [
  "signal", [
    "init, close", `Quick, begin fun () ->
      with_signal ignore
    end;

    "start, stop", `Quick, begin fun () ->
      with_signal begin fun signal ->
        let called = ref false in

        check_success_result "start" @@
        Luv.Signal.(start signal sighup) begin fun () ->
          Luv.Signal.stop signal |> check_success_result "stop";
          called := true
        end;
        send_signal ();

        run ();

        Alcotest.(check bool) "called" true !called
      end
    end;

    "start_oneshot", `Quick, begin fun () ->
      with_signal begin fun signal ->
        Luv.Signal.(start_oneshot signal sighup) ignore
        |> check_success_result "start";

        send_signal ();
        run ()
      end
    end;

    "get_signum", `Quick, begin fun () ->
      with_signal begin fun signal ->
        Luv.Signal.(start signal sighup) ignore
        |> check_success_result "start";

        Luv.Signal.get_signum signal
        |> Alcotest.(check int) "signum" Luv.Signal.sighup
      end
    end;

    "start: exception", `Quick, begin fun () ->
      with_signal begin fun signal ->
        check_exception Exit begin fun () ->
          check_success_result "start" @@
          Luv.Signal.(start signal sighup) begin fun () ->
            Luv.Signal.stop signal |> check_success_result "stop";
            raise Exit
          end;
          send_signal ();

          run ()
        end
      end
    end;

    "start_oneshot: exception", `Quick, begin fun () ->
      with_signal begin fun signal ->
        check_exception Exit begin fun () ->
          Luv.Signal.(start_oneshot signal sighup) (fun () -> raise Exit)
          |> check_success_result "start_oneshot";

          send_signal ();
          run ()
        end
      end
    end;
  ]
]