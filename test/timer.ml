open Test_helpers

let init () =
  let timer =
    Luv.Timer.init ()
    |> check_success_result "init"
  in
  timer

let with_timer f =
  let timer = init () in

  let result = f timer in

  Luv.Handle.close timer;
  run ();

  result

let tests = [
  "timer", [
    "init, close", `Quick, begin fun () ->
      with_timer ignore
    end;

    "loop", `Quick, begin fun () ->
      with_timer begin fun timer ->
        Luv.Handle.get_loop timer
        |> check_pointer "loop" default_loop
      end
    end;

    "start", `Quick, begin fun () ->
      with_timer begin fun timer ->
        let finished = ref false in

        let timeout = 10 in
        let start_time = Unix.gettimeofday () in

        Luv.Timer.start timer timeout (fun () -> finished := true)
        |> check_success "start";

        run ();
        Alcotest.(check bool) "finished" true !finished;

        let elapsed = (Unix.gettimeofday ()) -. start_time in
        let minimum_allowed = (float_of_int (timeout - 1)) *. 1e-3 in
        let maximum_allowed = minimum_allowed *. 2. in

        if elapsed < minimum_allowed || elapsed > maximum_allowed then
          Alcotest.failf
            "%fms elapsed; %ims expected" (elapsed *. 1e3) timeout
      end
    end;

    "double start", `Quick, begin fun () ->
      with_timer begin fun timer ->
        let first_called = ref false in
        let second_called = ref false in

        Luv.Timer.start timer 0 (fun () -> first_called := true)
        |> check_success "first start";
        Luv.Timer.start timer 0 (fun () -> second_called := true)
        |> check_success "second start";

        run ();

        Alcotest.(check bool) "first called" false !first_called;
        Alcotest.(check bool) "second called" true !second_called
      end
    end;

    "repeated start leak", `Quick, begin fun () ->
      with_timer begin fun timer ->
        no_memory_leak begin fun _n ->
          Luv.Timer.start timer 0 (make_callback ())
          |> check_success "start"
        end
      end
    end;

    "stop", `Quick, begin fun () ->
      with_timer begin fun timer ->
        let called = ref false in

        Luv.Timer.start timer 0 (fun () -> called := true)
        |> check_success "start";

        Luv.Timer.stop timer
        |> check_success "stop";

        run ();
        Alcotest.(check bool) "called" false !called
      end
    end;

    (* Mainly tests that the OCaml callback is not deallocated by stop. *)
    "again", `Quick, begin fun () ->
      with_timer begin fun timer ->
        let called = ref false in

        Luv.Timer.start timer 0 ~repeat:1 begin fun () ->
          Luv.Timer.stop timer
          |> check_success "stop";
          called := true
        end
        |> check_success "start";

        Luv.Timer.stop timer
        |> check_success "stop";

        Luv.Timer.again timer
        |> check_success "again";

        run ();
        Alcotest.(check bool) "called" true !called
      end
    end;

    (* Mainly tests that close releases references to the callback. *)
    "close leak", `Quick, begin fun () ->
      no_memory_leak begin fun _ ->
        let timer =
          Luv.Timer.init ()
          |> check_success_result "init"
        in

        Luv.Timer.start timer 0 ignore
        |> check_success "start";

        Luv.Handle.close timer;
        run ()
      end
    end;

    "double close", `Quick, begin fun () ->
      let timer = init () in

      Luv.Handle.close timer;
      run ();

      Gc.full_major ();

      Luv.Handle.close timer;
      run ()
    end;

    "multithreading", `Slow, begin fun () ->
      with_timer begin fun timer ->
        let ran = ref false in

        Luv.Timer.start timer 100 ignore
        |> check_success "start";

        ignore @@ Thread.create begin fun () ->
          Unix.sleepf 10e-3;
          ran := true
        end ();

        run ();

        Alcotest.(check bool) "ran" true !ran
      end
    end;

    (* Runs Loop.run in nowait mode. If calling Loop.run this way does not
       release the runtime lock, even though the call is non-blocking, when the
       callback tries to acquire the lock, there will be a deadlock. *)
    "busywait deadlock", `Slow, begin fun () ->
      with_timer begin fun timer ->
        let called = ref false in

        Luv.Timer.start timer 10 (fun () -> called := true)
        |> check_success "start";

        Unix.sleepf 20e-3;

        Luv.Loop.(run (default ()) Run_mode.nowait) |> ignore;

        Alcotest.(check bool) "called" true !called
      end
    end;

    "is_active, initial", `Quick, begin fun () ->
      with_timer begin fun timer ->
        Luv.Handle.is_active timer
        |> Alcotest.(check bool) "is_active" false
      end
    end;

    "is_active, started", `Quick, begin fun () ->
      with_timer begin fun timer ->
        Luv.Timer.start timer 0 ignore
        |> check_success "start";

        Luv.Handle.is_active timer
        |> Alcotest.(check bool) "is_active" true
      end
    end;

    "is_closing, initial", `Quick, begin fun () ->
      with_timer begin fun timer ->
        Luv.Handle.is_closing timer
        |> Alcotest.(check bool) "is_closing" false
      end
    end;

    "is_closing, closing", `Quick, begin fun () ->
      with_timer begin fun timer ->
        Luv.Handle.close timer;

        Luv.Handle.is_closing timer
        |> Alcotest.(check bool) "is_closing" true
      end
    end;

    "is_closing, closed", `Quick, begin fun () ->
      with_timer begin fun timer ->
        Luv.Handle.close timer;
        run ();

        Luv.Handle.is_closing timer
        |> Alcotest.(check bool) "is_closing" true
      end
    end;

    "has_ref", `Quick, begin fun () ->
      with_timer begin fun timer ->
        Luv.Handle.has_ref timer
        |> Alcotest.(check bool) "has_ref" true
      end
    end;

    "ref", `Quick, begin fun () ->
      with_timer begin fun timer ->
        Luv.Handle.ref timer;
        Luv.Handle.has_ref timer
        |> Alcotest.(check bool) "has_ref" true
      end
    end;

    "unref", `Quick, begin fun () ->
      with_timer begin fun timer ->
        Luv.Handle.unref timer;
        Luv.Handle.has_ref timer
        |> Alcotest.(check bool) "has_ref" false
      end
    end;
  ]
]

(* DOC note that callbacks shouldn't raise. *)
