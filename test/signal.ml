open Test_helpers

let with_signal f =
  let signal =
    Luv.Signal.init ()
    |> check_success_result "init"
  in

  f signal;

  Luv.Handle.close signal;
  run ()

let send_sigusr1 () =
  Unix.kill (Unix.getpid ()) Sys.sigusr1

let sigusr1 = Luv.C.Types.Signal.sigusr1_for_testing

(* TODO Document that the signal numbers are not the ones in module Sys. *)
let tests = [
  "signal", [
    "init, close", `Quick, begin fun () ->
      with_signal ignore
    end;

    "start, stop", `Quick, begin fun () ->
      with_signal begin fun signal ->
        Luv.Signal.start
          signal ~signum:sigusr1 ~callback:(fun signal' signum ->

          if not (signal' == signal) then
            Alcotest.fail "same handle";
          if not (signum = sigusr1) then
            Alcotest.fail "signum";
          Luv.Signal.stop signal
          |> check_success "stop")
        |> check_success "start";

        send_sigusr1 ();
        run ()
      end
    end;

    "start_oneshot", `Quick, begin fun () ->
      with_signal begin fun signal ->
        Luv.Signal.start_oneshot signal ~signum:sigusr1 ~callback:(fun _ _ ->
          ())
        |> check_success "start";

        send_sigusr1 ();
        run ()
      end
    end;

    "get_signum", `Quick, begin fun () ->
      with_signal begin fun signal ->
        Luv.Signal.start signal ~signum:sigusr1 ~callback:(fun _ _ -> ())
        |> check_success "start";

        Luv.Signal.get_signum signal
        |> Alcotest.(check int) "signum" sigusr1
      end
    end;
  ]
]