(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



open Test_helpers

let test_fd =
  if Sys.win32 then
    Luv.Process.stderr
  else begin
    (* On Linux in Travis, trying to create a poll handle for STDERR results in
       EPERM, so we create a dummy pipe instead. We don't bother closing it:
       only one will be created on tester startup, and it will be closed by the
       system on process exit. *)
    let (_read_end, write_end) = Unix.pipe () in
    (Obj.magic write_end : int)
  end

let with_poll f =
  let poll =
    Luv.Poll.init test_fd
    |> check_success_result "init"
  in

  f poll;

  Luv.Handle.close poll ignore;
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
          |> check_success_result "stop";

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

    (* This is a compilation test. If the type constraints in handle.mli are
       wrong, there will be a type error in this test. *)
    "handle functions", `Quick, begin fun () ->
      with_poll begin fun poll ->
        ignore @@ Luv.Handle.fileno poll
      end
    end;
  ]
]
