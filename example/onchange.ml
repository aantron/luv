let () =
  match Array.to_list Sys.argv with
  | [] | [_] | [_; _] ->
    Printf.eprintf "Usage: onchange <command> <file1> [file2]..."

  | _::command::files ->
    files |> List.iter begin fun target ->
      let watcher = Luv.FS_event.init () |> Result.get_ok in

      Luv.FS_event.start ~recursive:true watcher target begin function
        | Error e ->
          Printf.eprintf
            "Error watching %s: %s\n" target (Luv.Error.strerror e);
          ignore (Luv.FS_event.stop watcher);
          Luv.Handle.close watcher ignore

        | Ok (file, events) ->
          if List.mem `RENAME events then
            prerr_string "renamed ";
          if List.mem `CHANGE events then
            prerr_string "changed ";
          prerr_endline file;

          let exit_status = Sys.command command in
          if exit_status <> 0 then
            Stdlib.exit exit_status
      end
    end;

  ignore (Luv.Loop.run () : bool)
