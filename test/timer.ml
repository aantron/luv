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

    (* TODO Restore. *)
    (* "type", `Quick, begin fun () ->
      with_timer begin fun timer ->
        Luv.Handle.get_type timer
        |> check_handle_type Luv.Handle.Type.timer
      end
    end; *)
    (* TODO Restore. *)

    "start", `Quick, begin fun () ->
      with_timer begin fun timer ->
        let finished = ref false in

        let timeout = 10 in
        let start_time = Unix.gettimeofday () in

        Luv.Loop.update_time default_loop;
        Luv.Timer.start timer ~timeout ~repeat:0 ~callback:(fun timer' ->
          if not (timer' == timer) then
            Alcotest.fail "same timer";
          finished := true)
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

    (* This test fails with a segfault if the FFI does not retain a reference to
       the callback and the timer internally. The timer has to be retained, even
       though the callback argument is a fresh Ctypes value, because otherwise
       Ctypes frees the underlying C memory when the original Ctypes timer value
       is released. *)
    "gc", `Quick, begin fun () ->
      let timer =
        Luv.Timer.init ()
        |> check_success_result "init"
      in

      Gc.full_major ();

      let called = ref false in

      Luv.Timer.start timer ~timeout:0 ~repeat:0 ~callback:(fun arg_timer ->
        Luv.Handle.close arg_timer;
        called := true)
      |> check_success "start";

      Gc.full_major ();

      run ();
      Alcotest.(check bool) "called" true !called
    end;

    "double start", `Quick, begin fun () ->
      with_timer begin fun timer ->
        let first_called = ref false in
        let second_called = ref false in

        Luv.Timer.start timer ~timeout:0 ~repeat:0 ~callback:(fun _ ->
          first_called := true)
        |> check_success "first start";
        Luv.Timer.start timer ~timeout:0 ~repeat:0 ~callback:(fun _ ->
          second_called := true)
        |> check_success "second start";

        run ();

        Alcotest.(check bool) "first called" false !first_called;
        Alcotest.(check bool) "second called" true !second_called
      end
    end;

    "repeated start leak", `Quick, begin fun () ->
      with_timer begin fun timer ->
        no_memory_leak begin fun _n ->
          Luv.Timer.start
            timer ~timeout:0 ~repeat:0 ~callback:(make_callback ())
          |> check_success "start"
        end
      end
    end;

    "stop", `Quick, begin fun () ->
      with_timer begin fun timer ->
        let called = ref false in

        Luv.Timer.start timer ~timeout:0 ~repeat:0 ~callback:(fun _ ->
          called := true)
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

        Luv.Timer.start timer ~timeout:0 ~repeat:1 ~callback:(fun _ ->
          Luv.Timer.stop timer
          |> check_success "stop";
          called := true)
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

        Luv.Timer.start timer ~timeout:0 ~repeat:0 ~callback:ignore
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

    "use after close", `Quick, begin fun () ->
      let timer = init () in

      Luv.Handle.close timer;
      run ();

      Gc.full_major ();

      Alcotest.check_raises
        "use"
        Luv.Handle.Handle_already_closed_this_is_a_programming_logic_error
        (fun () -> Luv.Timer.stop timer |> ignore)
    end;

(* TODO Restore *)
(*
    "multithreading", `Quick, begin fun () ->
      with_timer begin fun timer ->
        let ran = ref false in

        Luv.Loop.update_time default_loop;
        Luv.Timer.start timer ~timeout:100 ~repeat:0 ~callback:ignore
        |> check_success "start";

        ignore @@ Thread.create begin fun () ->
          Unix.sleepf 10e-3;
          ran := true
        end ();

        run ();

        Alcotest.(check bool) "ran" true !ran
      end
    end;
*)
    "is_active, initial", `Quick, begin fun () ->
      with_timer begin fun timer ->
        Luv.Handle.is_active timer
        |> Alcotest.(check bool) "is_active" false
      end
    end;

    "is_active, started", `Quick, begin fun () ->
      with_timer begin fun timer ->
        Luv.Timer.start timer ~timeout:0 ~repeat:0 ~callback:ignore
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

(* TODO Release locks on a per-call basis. *)
(* TODO Test walk *)
(* TODO What should callback labels be? *)
(* TODO Docs: note that callbacks shouldn't raise. *)
