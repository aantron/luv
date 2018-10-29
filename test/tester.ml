let () =
  Alcotest.run "luv" (List.flatten [
    (* Error.tests;
    Version.tests;
    Loop.tests;
    Timer.tests;
    Loop_watcher.tests;
    Async.tests;
    Poll.tests;
    Signal.tests;
    TCP.tests;
    File.tests;
    Pipe.tests;
    Process.tests; *)
    Thread_.tests;
  ])

(* TODO Apply Bisect_ppx. *)
