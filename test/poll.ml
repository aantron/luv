open Test_helpers

let with_poll f =
  let poll =
    Luv.Poll.init Luv.Process.stderr
    |> check_success_result "init"
  in

  f poll;

  Luv.Handle.close poll;
  run ()

let tests = [
  "poll", [
    "init, close", `Quick, begin fun () ->
      with_poll ignore
    end;

    "start, stop", `Quick, begin fun () ->
      with_poll begin fun poll ->
        let called = ref false in

        Luv.Poll.(start poll Event.writable) begin fun result ->
          check_success_result "result" result
          |> Luv.Poll.Event.(test writable)
          |> Alcotest.(check bool) "writable" true;

          Luv.Poll.stop poll
          |> check_success "stop";

          called := true
        end;

        run ();

        Alcotest.(check bool) "called" true !called
      end
    end;

    "exception", `Quick, begin fun () ->
      with_poll begin fun poll ->
        check_exception Exit begin fun () ->
          Luv.Poll.(start poll Event.writable) begin fun _ ->
            Luv.Poll.stop poll |> ignore;
            raise Exit
          end;

          run ()
        end
      end
    end;
  ]
]
