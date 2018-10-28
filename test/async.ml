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
        Luv.Async.init begin fun async' ->
          begin
            match !async_cell with
            | Some async when async' == async -> ()
            | _ -> Alcotest.fail "same handle"
          end;
          called := true
        end
        |> check_success_result "init"
      in
      async_cell := Some async;

      Luv.Async.send async
      |> check_success "send";

      Luv.Loop.run default_loop Luv.Loop.Run_mode.nowait |> ignore;

      Luv.Handle.close async;
      run ();

      Alcotest.(check bool) "called" true !called
    end;

(* TODO Restore. *)
(*
    "multithreading", `Quick, begin fun () ->
      let called = ref false in
      let async =
        Luv.Async.init () ~callback:(fun async ->
          called := true;
          Luv.Handle.close async)
        |> check_success_result "init"
      in

      ignore @@ Thread.create begin fun () ->
        Unix.sleepf 10e-3;
        Luv.Async.send async
      end ();

      run ();

      Alcotest.(check bool) "called" true !called
    end; *)
  ]
]
