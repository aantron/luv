(* TODO Use a pipe? *)
(* TODO Does this test work on Windows? *)

open Test_helpers

let with_poll f =
  let poll =
    Luv.Poll.init ~fd:1 ()
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
        Luv.Poll.start poll [`Writable] ~callback:(fun poll' result events ->
          if not (poll' == poll) then
            Alcotest.fail "same handle";
          check_success "result" result;
          if not (events = [`Writable]) then
            Alcotest.fail "events";
          Luv.Poll.stop poll
          |> check_success "stop")
        |> check_success "start";

        run ()
      end
    end;
  ]
]
