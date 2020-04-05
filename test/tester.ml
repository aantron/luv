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
  with_fs_event begin fun _event ->
    let occurred = ref false in

    open_out filename |> close_out;

    let start = Unix.gettimeofday () in

    Printf.printf "start of test\n%!";

      Printf.printf "touch %f\n%!" ((Unix.gettimeofday () -. start) *. 1e3);
      let oc = open_out filename in
      Printf.printf "write %f\n%!" ((Unix.gettimeofday () -. start) *. 1e3);
      let () = Printf.fprintf oc "foo" in
      Printf.printf "close %f\n%!" ((Unix.gettimeofday () -. start) *. 1e3);
      close_out oc;

    Printf.printf "run %f\n%!" ((Unix.gettimeofday () -. start) *. 1e3);
    Printf.printf "run 2 %f\n%!" ((Unix.gettimeofday () -. start) *. 1e3);

    (* run (); *)

    Printf.printf "end %f\n%!" ((Unix.gettimeofday () -. start) *. 1e3);

    Alcotest.(check bool) "occurred" true !occurred;
    Alcotest.(check (float 0.1)) "delay < 100ms" 0.
      (Unix.gettimeofday () -. start)
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
