(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



open Test_helpers

let filename = "fs_poll"

let with_fs_poll f =
  if Sys.file_exists filename then
    Sys.remove filename;

  let poll = Luv.FS_poll.init () |> check_success_result "init" in

  f poll;

  Luv.Handle.close poll ignore;
  run ()

let after time f =
  let timer = Luv.Timer.init () |> check_success_result "timer" in
  Luv.Timer.start timer time begin fun () ->
    Luv.Handle.close timer ignore;
    f ()
  end
  |> check_success_result "timer_start"

let tests = [
  "fs_poll", [
    "init, close", `Quick, begin fun () ->
      with_fs_poll ignore
    end;

    "start, stop", `Quick, begin fun () ->
      with_fs_poll begin fun poll ->
        let occurred = ref false in
        let timed_out = ref false in

        Luv.FS_poll.start
          poll Filename.current_dir_name (fun _ -> occurred := true);

        after 10 begin fun () ->
          Luv.FS_poll.stop poll |> check_success_result "stop";
          timed_out := true
        end;

        run ();

        Alcotest.(check bool) "timed out" true !timed_out;
        Alcotest.(check bool) "occurred" false !occurred
      end
    end;

    "create", `Quick, begin fun () ->
      with_fs_poll begin fun poll ->
        let occurred = ref false in

        Luv.FS_poll.start poll ~interval:100 filename begin fun result ->
          match result with
          | Result.Error e when e = Luv.Error.enoent -> ()
          | _ ->
            Luv.FS_poll.stop poll |> check_success_result "stop";
            check_success_result "start" result |> ignore;
            occurred := true
        end;

        after 100 (fun () -> open_out filename |> close_out);

        run ();

        Alcotest.(check bool) "occurred" true !occurred
      end
    end;
  ]
]
