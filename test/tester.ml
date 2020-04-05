(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



open Test_helpers

let filename = "fs_event"

let with_fs_event f =
  if Sys.file_exists filename then
    Sys.remove filename;

  let event = Luv.FS_event.init () |> check_success_result "init" in

  f event;

  Luv.Handle.close event ignore;
  run ()

let () =
  with_fs_event begin fun event ->
    let occurred = ref false in

    open_out filename |> close_out;

    Luv.FS_event.start event filename begin fun result ->
      Luv.FS_event.stop event |> check_success_result "stop";
      let filename', events = check_success_result "start" result in
      Alcotest.(check string) "filename" filename filename';
      Alcotest.(check bool) "rename" false (List.mem `RENAME events);
      Alcotest.(check bool) "change" true (List.mem `CHANGE events);
      occurred := true
    end;

    let start = ref 0. in

    (* let timer = Luv.Timer.init () |> check_success_result "timer init" in
    check_success_result "timer start" @@
    Luv.Timer.start timer 100 begin fun () -> *)
      start := Unix.gettimeofday ();
      let oc = open_out filename in
      let () = Printf.fprintf oc "foo" in
      close_out oc;
    (* end; *)

    run ();

    Alcotest.(check bool) "occurred" true !occurred;
    Alcotest.(check (float 0.1)) "delay < 100ms" 0.
      (Unix.gettimeofday () -. !start)
  end

  (* Alcotest.run "luv" (List.flatten [ *)
    (* Error.tests;
    Version.tests;
    Loop.tests;
    Timer.tests;
    Loop_watcher.tests;
    Async.tests;
    if not Sys.win32 then Poll.tests else [];
    if not Sys.win32 then Signal.tests else [];
    TCP.tests;
    if not Sys.win32 then Pipe.tests else [];
    UDP.tests;
    TTY.tests;
    File.tests;
    if not Sys.win32 then Process.tests else []; *)
    (* FS_event.tests; *)
    (* FS_poll.tests;
    DNS.tests;
    Thread_.tests;
    Misc.tests; *)
  (* ]) *)
