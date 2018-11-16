let () =
  Alcotest.run "luv" (List.flatten [
    Error.tests;
    Version.tests;
    Loop.tests;
    Timer.tests;
    Loop_watcher.tests;
    Async.tests;
    Poll.tests;
    Signal.tests;
    TCP.tests;
    Pipe.tests;
    UDP.tests;
    TTY.tests;
    File.tests;
    Process.tests;
    FS_event.tests;
    FS_poll.tests;
    DNS.tests;
    Thread_.tests;
  ])
