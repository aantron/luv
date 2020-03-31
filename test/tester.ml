(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let () =
  Alcotest.run "luv" (List.flatten [
    Error.tests;
    Version.tests;
    Loop.tests;
    Timer.tests;
    Loop_watcher.tests;
    Async.tests;
    Poll.tests;
    if not Sys.win32 then Signal.tests else [];
    TCP.tests;
    if not Sys.win32 then Pipe.tests else [];
    UDP.tests;
    TTY.tests;
    File.tests;
    if not Sys.win32 then Process.tests else [];
    FS_event.tests;
    FS_poll.tests;
    DNS.tests;
    Thread_.tests;
    Misc.tests;
  ])
