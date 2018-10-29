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

      let async_cell = ref None in
      let async =
        check_success_result "init" @@
        Luv.Async.init begin fun async' ->
          begin
            match !async_cell with
            | Some async when async' == async -> ()
            | _ -> Alcotest.fail "same handle"
          end;
          called := true
        end
      in
      async_cell := Some async;

      Luv.Async.send async
      |> check_success "send";

      Luv.Loop.run default_loop Luv.Loop.Run_mode.nowait |> ignore;

      Luv.Handle.close async;
      run ();

      Alcotest.(check bool) "called" true !called
    end;

    "multithreading", `Quick, begin fun () ->
      let called = ref false in
      let async =
        check_success_result "init" @@
        Luv.Async.init begin fun async ->
          called := true;
          Luv.Handle.close async
        end
      in

      ignore @@ Thread.create begin fun () ->
        Unix.sleepf 10e-3;
        Luv.Async.send async
      end ();

      run ();

      Alcotest.(check bool) "called" true !called
    end;
  ]
]
