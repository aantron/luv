open Test_helpers

let with_signal f =
  let signal =
    Luv.Signal.init ()
    |> check_success_result "init"
  in

  f signal;

  Luv.Handle.close signal;
  run ()

let send_signal () =
  Unix.kill (Unix.getpid ()) Sys.sigint

let tests = [
  "signal", [
    "init, close", `Quick, begin fun () ->
      with_signal ignore
    end;

    "start, stop", `Quick, begin fun () ->
      with_signal begin fun signal ->
        Luv.Signal.(start signal sigint) begin fun signal' signum ->
          if not (signal' == signal) then
            Alcotest.fail "same handle";
          if not (signum = Luv.Signal.sigint) then
            Alcotest.fail "signum";
          Luv.Signal.stop signal
          |> check_success "stop"
        end
        |> check_success "start";

        send_signal ();
        run ()
      end
    end;

    "start_oneshot", `Quick, begin fun () ->
      with_signal begin fun signal ->
        Luv.Signal.(start_oneshot signal sigint) (fun _ -> ignore)
        |> check_success "start";

        send_signal ();
        run ()
      end
    end;

    "get_signum", `Quick, begin fun () ->
      with_signal begin fun signal ->
        Luv.Signal.(start signal sigint) (fun _ -> ignore)
        |> check_success "start";

        Luv.Signal.get_signum signal
        |> Alcotest.(check int) "signum" Luv.Signal.sigint
      end
    end;
  ]
]