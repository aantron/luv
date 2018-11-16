open Test_helpers

let tests = [
  "async", [
    "init, close", `Quick, begin fun () ->
      let async =
        Luv.Async.init ignore
        |> check_success_result "init"
      in

      Luv.Handle.close async;
      run ()
    end;

    "send", `Quick, begin fun () ->
      let called = ref false in

      let async =
        Luv.Async.init (fun _ -> called := true)
        |> check_success_result "init"
      in

      Luv.Async.send async |> check_success "send";
      Luv.Loop.(run default_loop Run_mode.nowait) |> ignore;
      Luv.Handle.close async;
      run ();

      Alcotest.(check bool) "called" true !called
    end;

    "multithreading", `Quick, begin fun () ->
      let called = ref false in

      let async =
        Luv.Async.init begin fun async ->
          called := true;
          Luv.Handle.close async
        end
        |> check_success_result "init"
      in

      ignore @@ Thread.create begin fun () ->
        Unix.sleepf 10e-3;
        Luv.Async.send async |> check_success "send"
      end ();

      run ();

      Alcotest.(check bool) "called" true !called
    end;

    "exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        let async =
          Luv.Async.init (fun _ -> raise Exit)
          |> check_success_result "init"
        in

        Luv.Async.send async |> check_success "send";
        Luv.Loop.(run default_loop Run_mode.nowait) |> ignore;
        Luv.Handle.close async;
        run ()
      end
    end;
  ]
]
