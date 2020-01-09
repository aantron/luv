(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



open Test_helpers

let for_watcher_kind init (start : _ -> (_ -> unit) -> _) stop =
  let with_watcher f =
    let watcher =
      init ()
      |> check_success_result "init"
    in

    let result = f watcher in

    Luv.Handle.close watcher ignore;
    run ();

    result
  in

  [
    "init, close", `Quick, begin fun () ->
      with_watcher ignore
    end;

    "loop", `Quick, begin fun () ->
      with_watcher begin fun watcher ->
        Luv.Handle.get_loop watcher
        |> check_pointer "loop" default_loop
      end
    end;

    "start, stop", `Quick, begin fun () ->
      with_watcher begin fun watcher ->
        let calls = ref 0 in

        check_success "start" @@
        start watcher begin fun () ->
          calls := !calls + 1;
          if !calls = 2 then
            stop watcher
            |> check_success "stop"
        end;

        while Luv.Loop.(run ~mode:Run_mode.nowait ()) do
          ()
        done;

        Alcotest.(check int) "calls" 2 !calls
      end
    end;

    "double start", `Quick, begin fun () ->
      with_watcher begin fun watcher ->
        let first_called = ref false in
        let second_called = ref false in

        start watcher (fun () -> first_called := true)
        |> check_success "first start";
        start watcher (fun () -> second_called := true)
        |> check_success "second start";

        Luv.Loop.(run ~mode:Run_mode.nowait ()) |> ignore;

        Alcotest.(check bool) "first called" true !first_called;
        Alcotest.(check bool) "second called" false !second_called
      end
    end;

    "exception", `Quick, begin fun () ->
      with_watcher begin fun watcher ->
        check_exception Exit begin fun () ->
          start watcher (fun () -> raise Exit)
          |> check_success "start";

          Luv.Loop.(run ~mode:Run_mode.nowait ()) |> ignore
        end
      end
    end;
  ]

let tests = [
  "prepare", Luv.Prepare.(for_watcher_kind init start stop);
  "check", Luv.Check.(for_watcher_kind init start stop);
  "idle", Luv.Check.(for_watcher_kind init start stop);
]
