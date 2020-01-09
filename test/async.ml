(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



open Test_helpers

let tests = [
  "async", [
    "init, close", `Quick, begin fun () ->
      let async =
        Luv.Async.init ignore
        |> check_success_result "init"
      in

      Luv.Handle.close async ignore;
      run ()
    end;

    "send", `Quick, begin fun () ->
      let called = ref false in

      let async =
        Luv.Async.init (fun _ -> called := true)
        |> check_success_result "init"
      in

      Luv.Async.send async |> check_success "send";
      Luv.Loop.(run ~mode:Run_mode.nowait ()) |> ignore;
      Luv.Handle.close async ignore;
      run ();

      Alcotest.(check bool) "called" true !called
    end;

    "multithreading", `Quick, begin fun () ->
      let called = ref false in

      let async =
        Luv.Async.init begin fun async ->
          called := true;
          Luv.Handle.close async ignore
        end
        |> check_success_result "init"
      in

      ignore @@ Thread.create begin fun () ->
        Unix.sleep 1;
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
        Luv.Loop.(run ~mode:Run_mode.nowait ()) |> ignore;
        Luv.Handle.close async ignore;
        run ()
      end
    end;
  ]
]
