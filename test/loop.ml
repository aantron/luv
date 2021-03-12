(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



open Test_helpers

let with_loop f =
  let loop =
    Luv.Loop.init ()
    |> check_success_result "init"
  in

  f loop;

  Luv.Loop.close loop
  |> check_success_result "close"

let tests = [
  "loop", [
    "init, close", `Quick, begin fun () ->
      with_loop ignore;
    end;

    "configure", `Quick, begin fun () ->
      with_loop begin fun loop ->
        let check_result =
          if not Sys.win32 then
            check_success_result "configure"
          else
            check_error_result "configure" `ENOSYS
        in

        Luv.Loop.configure
          loop Luv.Loop.Option.block_signal Luv.Loop.Option.sigprof
        |> check_result
      end
    end;

    "configure, invalid", `Quick, begin fun () ->
      with_loop begin fun loop ->
        Luv.Loop.configure loop Luv.Loop.Option.block_signal 0
        |> check_error_results "configure" [`EINVAL; `ENOSYS]
      end
    end;

    "default", `Quick, begin fun () ->
      Luv.Loop.default ()
      |> check_not_null "default"
    end;

    (* All of these loops exit right away, because there are no active I/O
       requests at this point in the test runner. *)
    "run, default", `Quick, begin fun () ->
      with_loop begin fun loop ->
        Luv.Loop.run ~loop ~mode:`DEFAULT ()
        |> Alcotest.(check bool) "run" false
      end
    end;

    "run, once", `Quick, begin fun () ->
      with_loop begin fun loop ->
        Luv.Loop.run ~loop ~mode:`ONCE ()
        |> Alcotest.(check bool) "run" false
      end
    end;

    "run, nowait", `Quick, begin fun () ->
      with_loop begin fun loop ->
        Luv.Loop.run ~loop ~mode:`NOWAIT ()
        |> Alcotest.(check bool) "run" false
      end
    end;

    "alive", `Quick, begin fun () ->
      with_loop begin fun loop ->
        Luv.Loop.alive loop
        |> Alcotest.(check bool) "alive" false
      end
    end;

    "stop", `Quick, begin fun () ->
      with_loop (fun loop ->
        Luv.Loop.stop loop)
    end;

    "backend_fd", `Quick, begin fun () ->
      with_loop begin fun loop ->
        Luv.Loop.backend_fd loop
        |> ignore
      end
    end;

    "backend_timeout", `Quick, begin fun () ->
      with_loop begin fun loop ->
        Luv.Loop.backend_timeout loop
        |> Alcotest.(check (option int)) "backend_timeout" (Some 0)
      end
    end;

    "now", `Quick, begin fun () ->
      with_loop begin fun loop ->
        Luv.Loop.now loop
        |> fun time ->
          if Unsigned.UInt64.(compare time zero) <= 0 then
            Alcotest.fail "libuv time not positive"
      end
    end;

    "update_time", `Quick, begin fun () ->
      with_loop begin fun loop ->
        let initial_libuv_time =
          Luv.Loop.now loop
          |> Unsigned.UInt64.to_int
        in
        Luv.Loop.update_time loop;
        let new_libuv_time =
          Luv.Loop.now loop
          |> Unsigned.UInt64.to_int
        in
        let difference = new_libuv_time - initial_libuv_time in
        if difference > 1 then
          Alcotest.failf "libuv times differ by %ims" difference
      end
    end;
  ]
]
