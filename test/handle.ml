(* TODO Make sure is_active is exercised on all subtypes. *)

let tests = [
  "handle", [
    "type", `Quick, begin fun () ->
      let open Luv.Handle.Type in
      Alcotest.(check int) "async" 1 (async :> int);
      Alcotest.(check int) "check" 2 (check :> int);
      Alcotest.(check int) "fs_event" 3 (fs_event :> int);
      Alcotest.(check int) "fs_poll" 4 (fs_poll :> int);
      Alcotest.(check int) "handle" 5 (handle :> int);
      Alcotest.(check int) "idle" 6 (idle :> int);
      Alcotest.(check int) "named_pipe" 7 (named_pipe :> int);
      Alcotest.(check int) "poll" 8 (poll :> int);
      Alcotest.(check int) "prepare" 9 (prepare :> int);
      Alcotest.(check int) "process" 10 (process :> int);
      Alcotest.(check int) "stream" 11 (stream :> int);
      Alcotest.(check int) "tcp" 12 (tcp :> int);
      Alcotest.(check int) "timer" 13 (timer :> int);
      Alcotest.(check int) "tty" 14 (tty :> int);
      Alcotest.(check int) "udp" 15 (udp :> int);
      Alcotest.(check int) "signal" 16 (signal :> int);
      Alcotest.(check int) "file" 17 (file :> int);
    end;

    "name", `Quick, begin fun () ->
      let t name type_ =
        Alcotest.(check string) name name (Luv.Handle.type_name type_)
      in
      let open Luv.Handle.Type in
      t "async" async;
      t "check" check;
      t "fs_event" fs_event;
      t "fs_poll" fs_poll;
      t "handle" handle;
      t "idle" idle;
      t "pipe" named_pipe;
      t "poll" poll;
      t "prepare" prepare;
      t "process" process;
      t "stream" stream;
      t "tcp" tcp;
      t "timer" timer;
      t "tty" tty;
      t "udp" udp;
      t "signal" signal;
      t "file" file;
    end;

    "data", `Quick, begin fun () ->
      let data = 42 in
      let handle = Ctypes.make Luv.Handle.t in

      data
      |> Nativeint.of_int
      |> Ctypes.ptr_of_raw_address
      |> Luv.Handle.set_data (Ctypes.addr handle);

      Luv.Handle.get_data (Ctypes.addr handle)
      |> Ctypes.raw_address_of_ptr
      |> Nativeint.to_int
      |> Alcotest.(check int) "value" data
    end;

    (* TODO Call size on all handle types not tested elsewhere. This probably
       includes at least unknown and the base handle. Try it on a negative
       argument? *)
  ]
]