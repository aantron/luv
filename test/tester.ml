let () =
  Alcotest.run "luv" (List.flatten [
    Error.tests;
    Version.tests;
    Loop.tests;
    (* Handle.tests; *)
    (* Request.tests; *)
    Timer.tests;
    Loop_watcher.tests;
    Async.tests;
    Poll.tests;
    Signal.tests;
    TCP.tests;
    File.tests;
    Pipe.tests;
    Process.tests;
  ])

(* TODO Apply Bisect_ppx. *)
