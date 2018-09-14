open Test_helpers

let with_loop f =
  let loop =
    Luv.Loop.init ()
    |> check_success_result "init"
  in

  f loop;

  Luv.Loop.close loop
  |> check_success "close"

let tests = [
  "loop", [
    "data", `Quick, begin fun () ->
      with_loop begin fun loop ->
        let data = 42 in

        data
        |> Nativeint.of_int
        |> Ctypes.ptr_of_raw_address
        |> Luv.Loop.set_data loop;

        Luv.Loop.get_data loop
        |> Ctypes.raw_address_of_ptr
        |> Nativeint.to_int
        |> Alcotest.(check int) "value" data
      end
    end;

    "init, close", `Quick, begin fun () ->
      with_loop ignore;
    end;

    "configure", `Quick, begin fun () ->
      with_loop begin fun loop ->
        Luv.Loop.configure
          loop Luv.Loop.Option.block_signal Luv.Loop.Option.sigprof
        |> check_success "configure"
      end
    end;

    "configure, invalid", `Quick, begin fun () ->
      with_loop begin fun loop ->
        Luv.Loop.configure loop Luv.Loop.Option.block_signal 0
        |> check_error_code "configure" Luv.Error.Code.einval
      end
    end;

    "default", `Quick, begin fun () ->
      Luv.Loop.default ()
      |> check_not_null "default"
    end;

    "run mode", `Quick, begin fun () ->
      Alcotest.(check int) "default" 0 (Luv.Loop.Run_mode.default :> int);
      Alcotest.(check int) "once" 1 (Luv.Loop.Run_mode.once :> int);
      Alcotest.(check int) "nowait" 2 (Luv.Loop.Run_mode.nowait :> int);
    end;

    (* All of these loops exit right away, because there are no active I/O
       requests at this point in the test runner. *)
    "run, default", `Quick, begin fun () ->
      with_loop begin fun loop ->
        Luv.Loop.run loop Luv.Loop.Run_mode.default
        |> Alcotest.(check bool) "run" false
      end
    end;

    "run, once", `Quick, begin fun () ->
      with_loop begin fun loop ->
        Luv.Loop.run loop Luv.Loop.Run_mode.once
        |> Alcotest.(check bool) "run" false
      end
    end;

    "run, nowait", `Quick, begin fun () ->
      with_loop begin fun loop ->
        Luv.Loop.run loop Luv.Loop.Run_mode.nowait
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
        |> Alcotest.(check int) "backend_timeout" 0
      end
    end;

    "now", `Quick, begin fun () ->
      with_loop begin fun loop ->
        Luv.Loop.now loop
        |> Unsigned.UInt64.to_int
        |> fun time ->
          if time <= 0 then
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
