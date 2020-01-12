open Test_helpers

let with_file_for_reading ?(to_fail = false) f =
  let flags =
    if not to_fail then
      [`RDONLY]
    else
      [`WRONLY]
  in

  let file =
    Luv.File.(Sync.open_ "read_test_input" flags)
    |> check_success_result "open_"
  in

  f file;

  Luv.File.Sync.close file
  |> check_success_result "close"

let with_file_for_writing f =
  let filename = "write_test_output" in

  let file =
    Luv.File.(Sync.open_ filename [`WRONLY; `CREAT; `TRUNC])
    |> check_success_result "open_";
  in

  f file;

  Luv.File.Sync.close file
  |> check_success_result "close";

  let channel = open_in filename in
  let content = input_line channel in
  close_in channel;

  Alcotest.(check string) "content" "ope" content

let with_dummy_file f =
  let filename = "test_dummy" in

  open_out filename |> close_out;

  f filename;

  if Sys.file_exists filename then
    Sys.remove filename

let with_directory f =
  let directory = "dir" in
  let file_1 = "dir/foo" in
  let file_2 = "dir/bar" in

  Unix.mkdir "dir" 0o755;
  open_out file_1 |> close_out;
  open_out file_2 |> close_out;

  f directory;

  Sys.remove file_1;
  Sys.remove file_2;
  Unix.rmdir directory

let call_scandir_next_repeatedly scan =
  let rec repeat entry_accumulator =
    match Luv.File.Directory_scan.next scan with
    | Some entry ->
      repeat (entry::entry_accumulator)
    | None ->
      Luv.File.Directory_scan.stop scan;
      entry_accumulator
  in
  repeat []

let tests = [
  "file", [
    "open, read, close: async", `Quick, begin fun () ->
      let finished = ref false in

      Luv.File.Async.open_ "read_test_input" [`RDONLY] begin fun result ->
        let file = check_success_result "file" result in

        let buffer = Luv.Bigstring.create 4 in
        Luv.Bigstring.fill buffer '\000';

        Luv.File.Async.read file [buffer] begin fun result ->
          let length =
            check_success_result "read result" result
            |> Unsigned.Size_t.to_int
          in
          Alcotest.(check int) "byte count" 4 length;

          Luv.Bigstring.sub buffer ~offset:0 ~length
          |> Luv.Bigstring.to_string
          |> Alcotest.(check string) "data" "open";

          Luv.File.Async.close file begin fun result ->
            check_success_result "close result" result;
            finished := true
          end
        end
      end;

      run ();

      Alcotest.(check bool) "finished" true !finished
    end;

    "open, read, close: sync", `Quick, begin fun () ->
      let file =
        Luv.File.Sync.open_ "read_test_input" [`RDONLY]
        |> check_success_result "open_"
      in

      let buffer = Luv.Bigstring.create 4 in
      Luv.Bigstring.fill buffer '\000';

      let length =
        Luv.File.Sync.read file [buffer]
        |> check_success_result "read"
        |> Unsigned.Size_t.to_int
      in

      Alcotest.(check int) "byte count" 4 length;

      Luv.Bigstring.sub buffer ~offset:0 ~length
      |> Luv.Bigstring.to_string
      |> Alcotest.(check string) "data" "open";

      Luv.File.Sync.close file
      |> check_success_result "close"
    end;

    "open: nonexistent, async", `Quick, begin fun () ->
      let result = ref (Result.Error `UNKNOWN) in

      Luv.File.Async.open_ "non_existent_file" [`RDONLY] begin fun result' ->
        result := result'
      end;

      run ();
      check_error_result "result" `ENOENT !result
    end;

    "open: nonexistent, sync", `Quick, begin fun () ->
      Luv.File.Sync.open_ "non_existent_file" [`RDONLY]
      |> check_error_result "open_" `ENOENT
    end;

    "open, close: memory leak, async", `Quick, begin fun () ->
      no_memory_leak begin fun _ ->
        let finished = ref false in

        Luv.File.Async.open_ "file.ml" [`RDONLY] begin fun result ->
          let file = check_success_result "file" result in
          Luv.File.Async.close file begin fun _ ->
            finished := true
          end
        end;

        run ();
        Alcotest.(check bool) "finished" true !finished
      end
    end;

    "open, close: memory leak, sync", `Quick, begin fun () ->
      no_memory_leak begin fun _ ->
        let file =
          Luv.File.Sync.open_ "file.ml" [`RDONLY]
          |> check_success_result "open_"
        in

        Luv.File.Sync.close file
        |> check_success_result "close"
      end
    end;

    "open: failure leak, async", `Quick, begin fun () ->
      no_memory_leak begin fun _ ->
        Luv.File.Async.open_ "non_existent_file" [`RDONLY] begin fun result ->
          check_error_result "result" `ENOENT result
        end;

        run ()
      end
    end;

    "open: failure leak, sync", `Quick, begin fun () ->
      no_memory_leak begin fun _ ->
        Luv.File.Sync.open_ "non_existent_file" [`RDONLY]
        |> check_error_result "open_" `ENOENT;
      end
    end;

    "open: gc", `Quick, begin fun () ->
      Gc.full_major ();

      let called = ref false in

      Luv.File.Async.open_ "non_existent_file" [`RDONLY] begin fun _result ->
        called := true
      end;

      Gc.full_major ();

      run ();
      Alcotest.(check bool) "called" true !called
    end;

    "open: exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        Luv.File.Async.open_ "non_existent_file" [`RDONLY] begin fun _result ->
          raise Exit
        end;
        run ()
      end
    end;

    "read failure: async", `Quick, begin fun () ->
      with_file_for_reading ~to_fail:true begin fun file ->
        let buffer = Luv.Bigstring.create 1 in

        Luv.File.Async.read file [buffer] begin fun result ->
          check_error_result "byte_count" `EBADF result
        end;

        run ()
      end
    end;

    "read failure: sync", `Quick, begin fun () ->
      with_file_for_reading ~to_fail:true begin fun file ->
        let buffer = Luv.Bigstring.create 1 in

        Luv.File.Sync.read file [buffer]
        |> check_error_result "read" `EBADF
      end
    end;

    "read leak: async", `Quick, begin fun () ->
      with_file_for_reading begin fun file ->
        let buffer = Luv.Bigstring.create 1 in

        no_memory_leak begin fun _ ->
          let finished = ref false in

          Luv.File.Async.read file [buffer] begin fun _ ->
            finished := true
          end;

          run ();
          Alcotest.(check bool) "finished" true !finished
        end
      end
    end;

    "read leak: sync", `Quick, begin fun () ->
      with_file_for_reading begin fun file ->
        let buffer = Luv.Bigstring.create 1 in

        no_memory_leak begin fun _ ->
          Luv.File.Sync.read file [buffer]
          |> check_success_result "read"
          |> ignore;
        end
      end
    end;

    "read sync failure leak", `Quick, begin fun () ->
      with_file_for_reading begin fun file ->
        no_memory_leak begin fun _ ->
          Luv.File.Async.read file [] ignore;
          run ()
        end
      end
    end;

    "read gc", `Quick, begin fun () ->
      with_file_for_reading begin fun file ->
        Gc.full_major ();

        let called = ref false in
        let buffer = Luv.Bigstring.from_string "\000" in

        let finalized = ref false in
        Gc.finalise (fun _ -> finalized := true) buffer;

        Luv.File.Async.read file [buffer] begin fun _ ->
          called := true
        end;

        Gc.full_major ();
        Alcotest.(check bool) "finalized (1)" false !finalized;

        run ();
        Alcotest.(check bool) "called" true !called;

        Gc.full_major ();
        Alcotest.(check bool) "finalized (2)" true !finalized
      end
    end;

    "write: async", `Quick, begin fun () ->
      with_file_for_writing begin fun file ->
        let buffer = Luv.Bigstring.from_string "ope" in

        Luv.File.Async.write file [buffer] begin fun result ->
          let byte_count = check_success_result "write result" result in
          Alcotest.(check int)
            "byte count" 3 (Unsigned.Size_t.to_int byte_count)
        end;

        run ()
      end
    end;

    "write: sync", `Quick, begin fun () ->
      with_file_for_writing begin fun file ->
        let buffer = Luv.Bigstring.from_string "ope" in

        Luv.File.Sync.write file [buffer]
        |> check_success_result "write"
        |> ignore
      end
    end;

    "unlink: async", `Quick, begin fun () ->
      with_dummy_file begin fun path ->
        Alcotest.(check bool) "exists" true (Sys.file_exists path);

        Luv.File.Async.unlink path begin fun result ->
          check_success_result "result" result
        end;

        run ();
        Alcotest.(check bool) "does not exist" false (Sys.file_exists path)
      end
    end;

    "unlink: sync", `Quick, begin fun () ->
      with_dummy_file begin fun path ->
        Alcotest.(check bool) "exists" true (Sys.file_exists path);

        Luv.File.Sync.unlink path
        |> check_success_result "unlink";

        Alcotest.(check bool) "does not exist" false (Sys.file_exists path)
      end
    end;

    "unlink failure: async", `Quick, begin fun () ->
      let finished = ref false in

      Luv.File.Async.unlink "non_existent_file" begin fun result ->
        check_error_result "result" `ENOENT result;
        finished := true
      end;

      run ();
      Alcotest.(check bool) "finished" true !finished
    end;

    "unlink failure: sync", `Quick, begin fun () ->
      Luv.File.Sync.unlink "non_existent_file"
      |> check_error_result "unlink" `ENOENT
    end;

    "mkdir, rmdir: async", `Quick, begin fun () ->
      let finished = ref false in
      let directory = "dummy_directory" in

      Luv.File.Async.mkdir directory begin fun result ->
        check_success_result "mkdir result" result;
        Alcotest.(check bool) "exists" true (Sys.file_exists directory);

        Luv.File.Async.rmdir directory begin fun result ->
          check_success_result "rmdir result" result;
          Alcotest.(check bool)
            "does not exist" false (Sys.file_exists directory);

          finished := true
        end
      end;

      run ();
      Alcotest.(check bool) "finished" true !finished
    end;

    "mkdir, rmdir: sync", `Quick, begin fun () ->
      let directory = "dummy_directory" in

      Luv.File.Sync.mkdir directory
      |> check_success_result "mkdir";

      Alcotest.(check bool) "exists" true (Sys.file_exists directory);

      Luv.File.Sync.rmdir directory
      |> check_success_result "rmdir";

      Alcotest.(check bool) "does not exist" false (Sys.file_exists directory)
    end;

    "mkdir failure: async", `Quick, begin fun () ->
      with_dummy_file begin fun path ->
        let finished = ref false in

        Luv.File.Async.mkdir path begin fun result ->
          check_error_result "mkdir result" `EEXIST result;
          finished := true
        end;

        run ();
        Alcotest.(check bool) "finished" true !finished
      end
    end;

    "mkdir failure: sync", `Quick, begin fun () ->
      with_dummy_file begin fun path ->
        Luv.File.Sync.mkdir path
        |> check_error_result "mkdir" `EEXIST
      end
    end;

    "rmdir failure: async", `Quick, begin fun () ->
      let finished = ref false in

      Luv.File.Async.rmdir "non_existent_file" begin fun result ->
        check_error_result "rmdir result" `ENOENT result;
        finished := true
      end;

      run ();
      Alcotest.(check bool) "finished" true !finished
    end;

    "rmdir failure: sync", `Quick, begin fun () ->
      Luv.File.Sync.rmdir "non_existent_file"
      |> check_error_result "rmdir" `ENOENT
    end;

    "mkdtemp: async", `Quick, begin fun () ->
      let finished = ref false in

      Luv.File.Async.mkdtemp "fooXXXXXX" begin fun result ->
        let path = check_success_result "mkdtemp result" result in

        Luv.File.Async.rmdir path begin fun result ->
          check_success_result "rmdir result" result;
          finished := true
        end
      end;

      run ();
      Alcotest.(check bool) "finished" true !finished
    end;

    "mkdtemp: sync", `Quick, begin fun () ->
      let path =
        Luv.File.Sync.mkdtemp "fooXXXXXX"
        |> check_success_result "mkdtemp"
      in

      Luv.File.Sync.rmdir path
      |> check_success_result "rmdir"
    end;

    "mkdtemp failure: async", `Quick, begin fun () ->
      let finished = ref false in

      Luv.File.Async.mkdtemp "non-existent/fooXXXXXX" begin fun result ->
        check_error_result "mkdtemp result" `ENOENT result;
        finished := true
      end;

      run ();
      Alcotest.(check bool) "finished" true !finished
    end;

    "mkdtemp failure: sync", `Quick, begin fun () ->
      Luv.File.Sync.mkdtemp "non-existent/fooXXXXXX"
      |> check_error_result "mkdtemp result" `ENOENT
    end;

    "mkstemp: async", `Quick, begin fun () ->
      let finished = ref false in

      Luv.File.Async.mkstemp "fooXXXXXX" begin fun result ->
        let path, file = check_success_result "mkstemp result" result in

        Luv.File.Async.close file begin fun result ->
          check_success_result "close" result;

          Luv.File.Async.unlink path begin fun result ->
            check_success_result "unlink" result;
            finished := true
          end
        end
      end;

      run ();
      Alcotest.(check bool) "finished" true !finished
    end;

    "mkstemp: sync", `Quick, begin fun () ->
      let path, file =
        Luv.File.Sync.mkstemp "fooXXXXXX"
        |> check_success_result "mkstemp"
      in

      Luv.File.Sync.close file
      |> check_success_result "close";

      Luv.File.Sync.unlink path
      |> check_success_result "unlink"
    end;

    "mkstemp failure: async", `Quick, begin fun () ->
      let finished = ref false in

      Luv.File.Async.mkstemp "non-existent/fooXXXXXX" begin fun result ->
        check_error_result "mkstemp result" `ENOENT result;
        finished := true
      end;

      run ();
      Alcotest.(check bool) "finished" true !finished
    end;

    "mkstemp failure: sync", `Quick, begin fun () ->
      Luv.File.Sync.mkstemp "non-existent/fooXXXXXX"
      |> check_error_result "mkstemp result" `ENOENT
    end;

    "opendir, closedir: async", `Quick, begin fun () ->
      with_directory begin fun directory ->
        Luv.File.Async.opendir directory begin fun result ->
          let dir = check_success_result "opendir" result in
          Luv.File.Async.closedir dir (check_success_result "closedir")
        end;

        run ()
      end
    end;

    "opendir, closedir: sync", `Quick, begin fun () ->
      with_directory begin fun directory ->
        Luv.File.Sync.opendir directory
        |> check_success_result "opendir"
        |> Luv.File.Sync.closedir
        |> check_success_result "closedir"
      end
    end;

    "readdir: async", `Quick, begin fun () ->
      with_directory begin fun directory ->
        Luv.File.Async.opendir directory begin fun result ->
          let dir = check_success_result "opendir" result in

          Luv.File.Async.readdir dir begin fun result ->
            check_success_result "readdir" result
            |> Array.to_list
            |> check_directory_entries "entries" ["foo"; "bar"];

            Luv.File.Async.closedir dir (check_success_result "closedir")
          end
        end;

        run ()
      end
    end;

    "readdir: sync", `Quick, begin fun () ->
      with_directory begin fun directory ->
        let dir =
          Luv.File.Sync.opendir directory |> check_success_result "opendir" in

        Luv.File.Sync.readdir dir
        |> check_success_result "readdir"
        |> Array.to_list
        |> check_directory_entries "entries" ["foo"; "bar"];

        Luv.File.Sync.closedir dir |> check_success_result "closedir"
      end
    end;

    "readdir: limit", `Quick, begin fun () ->
      with_directory begin fun directory ->
        let dir =
          Luv.File.Sync.opendir directory |> check_success_result "opendir" in

        Luv.File.Sync.readdir ~number_of_entries:0 dir
        |> check_success_result "readdir"
        |> Array.to_list
        |> check_directory_entries "entries" [];

        Luv.File.Sync.closedir dir |> check_success_result "closedir"
      end
    end;

    "readdir: gc", `Quick, begin fun () ->
      with_directory begin fun directory ->
        Luv.File.Async.opendir directory begin fun result ->
          let dir = check_success_result "opendir" result in

          Luv.File.Async.readdir dir begin fun result ->
            check_success_result "readdir" result
            |> Array.to_list
            |> check_directory_entries "entries" ["foo"; "bar"];

            Luv.File.Async.closedir dir (check_success_result "closedir")
          end;

          Gc.full_major ();
        end;

        run ()
      end
    end;

    "scandir: async", `Quick, begin fun () ->
      with_directory begin fun directory ->
        let entries = ref [] in

        Luv.File.Async.scandir directory begin fun result ->
          entries :=
            check_success_result "scandir" result
            |> call_scandir_next_repeatedly
        end;

        run ();
        check_directory_entries "scandir_next" ["foo"; "bar"] !entries
      end
    end;

    "scandir: sync", `Quick, begin fun () ->
      with_directory begin fun directory ->
        Luv.File.Sync.scandir directory
        |> check_success_result "scandir"
        |> call_scandir_next_repeatedly
        |> check_directory_entries "scandir_next" ["foo"; "bar"]
      end
    end;

    "scandir failure: async", `Quick, begin fun () ->
      let finished = ref false in

      Luv.File.Async.scandir "non_existent_directory" begin fun result ->
        check_error_result "scandir" `ENOENT result;
        finished := true
      end;

      run ();
      Alcotest.(check bool) "finished" true !finished
    end;

    "scandir failure: sync", `Quick, begin fun () ->
      Luv.File.Sync.scandir "non_existent_directory"
      |> check_error_result "scandir" `ENOENT
    end;

    "stat: async", `Quick, begin fun () ->
      let size = ref 0 in

      Luv.File.Async.stat "file.ml" begin fun result ->
        check_success_result "stat" result
        |> fun stat -> size := Unsigned.UInt64.to_int Luv.File.Stat.(stat.size)
      end;

      run ();
      Alcotest.(check int) "size" Unix.((stat "file.ml").st_size) !size
    end;

    "stat: sync", `Quick, begin fun () ->
      Luv.File.Sync.stat "file.ml"
      |> check_success_result "stat"
      |> fun stat -> Luv.File.Stat.(stat.size)
      |> Unsigned.UInt64.to_int
      |> Alcotest.(check int) "size" Unix.((stat "file.ml").st_size)
    end;

    "stat failure: async", `Quick, begin fun () ->
      let finished = ref false in

      Luv.File.Async.stat "non_existent_file" begin fun result ->
        check_error_result "stat" `ENOENT result;
        finished := true
      end;

      run ();
      Alcotest.(check bool) "finished" true !finished
    end;

    "stat failure: sync", `Quick, begin fun () ->
      Luv.File.Sync.stat "non_existent_file"
      |> check_error_result "stat" `ENOENT
    end;

    "lstat: async", `Quick, begin fun () ->
      let size = ref 0 in

      Luv.File.Async.lstat "file.ml" begin fun result ->
        check_success_result "lstat" result
        |> fun stat -> size := Unsigned.UInt64.to_int Luv.File.Stat.(stat.size)
      end;

      run ();
      Alcotest.(check int) "size" Unix.((lstat "file.ml").st_size) !size
    end;

    "lstat: sync", `Quick, begin fun () ->
      Luv.File.Sync.lstat "file.ml"
      |> check_success_result "lstat"
      |> fun stat -> Luv.File.Stat.(stat.size)
      |> Unsigned.UInt64.to_int
      |> Alcotest.(check int) "size" Unix.((lstat "file.ml").st_size)
    end;

    "lstat failure: async", `Quick, begin fun () ->
      let finished = ref false in

      Luv.File.Async.lstat "non_existent_file" begin fun result ->
        check_error_result "lstat" `ENOENT result;
        finished := true
      end;

      run ();
      Alcotest.(check bool) "finished" true !finished
    end;

    "lstat failure: sync", `Quick, begin fun () ->
      Luv.File.Sync.lstat "non_existent_file"
      |> check_error_result "lstat" `ENOENT
    end;

    "fstat: async", `Quick, begin fun () ->
      let size = ref 0 in

      with_file_for_reading begin fun file ->
        Luv.File.Async.fstat file begin fun result ->
          check_success_result "fstat" result
          |> fun stat ->
            size := Unsigned.UInt64.to_int Luv.File.Stat.(stat.size)
        end;

        run ()
      end;

      Alcotest.(check int) "size" Unix.((stat "read_test_input").st_size) !size
    end;

    "fstat: sync", `Quick, begin fun () ->
      with_file_for_reading begin fun file ->
        Luv.File.Sync.fstat file
        |> check_success_result "fstat"
        |> fun stat -> Luv.File.Stat.(stat.size)
        |> Unsigned.UInt64.to_int
        |> Alcotest.(check int) "size" Unix.((stat "read_test_input").st_size)
      end
    end;

    "statfs: async", `Quick, begin fun () ->
      Luv.File.Async.statfs "file.ml" begin fun result ->
        check_success_result "stat" result |> ignore
      end;

      run ()
    end;

    "statfs: sync", `Quick, begin fun () ->
      Luv.File.Sync.statfs "file.ml"
      |> check_success_result "stat"
      |> ignore
    end;

    "statfs failure: async", `Quick, begin fun () ->
      let finished = ref false in

      Luv.File.Async.statfs "non_existent_file" begin fun result ->
        check_error_result "stat" `ENOENT result;
        finished := true
      end;

      run ();
      Alcotest.(check bool) "finished" true !finished
    end;

    "statfs failure: sync", `Quick, begin fun () ->
      Luv.File.Sync.statfs "non_existent_file"
      |> check_error_result "stat" `ENOENT
    end;

    "rename: async", `Quick, begin fun () ->
      with_dummy_file begin fun path ->
        let to_ = path ^ ".renamed" in

        Alcotest.(check bool) "original at start" true (Sys.file_exists path);
        Alcotest.(check bool) "new at start" false (Sys.file_exists to_);

        Luv.File.Async.rename ~from:path ~to_ (check_success_result "rename");
        run ();

        Alcotest.(check bool) "original at end" false (Sys.file_exists path);
        Alcotest.(check bool) "new at end" true (Sys.file_exists to_);

        Sys.remove to_
      end
    end;

    "rename: sync", `Quick, begin fun () ->
      with_dummy_file begin fun path ->
        let to_ = path ^ ".renamed" in

        Alcotest.(check bool) "original at start" true (Sys.file_exists path);
        Alcotest.(check bool) "new at start" false (Sys.file_exists to_);

        Luv.File.Sync.rename ~from:path ~to_
        |> check_success_result "rename";

        Alcotest.(check bool) "original at end" false (Sys.file_exists path);
        Alcotest.(check bool) "new at end" true (Sys.file_exists to_);

        Sys.remove to_
      end
    end;

    "rename failure: async", `Quick, begin fun () ->
      let finished = ref false in

      Luv.File.Async.rename ~from:"non_existent_file" ~to_:"foo"
          begin fun result ->

        check_error_result "rename" `ENOENT result;
        finished := true
      end;

      run ();
      Alcotest.(check bool) "finished" true !finished
    end;

    "rename failure: sync", `Quick, begin fun () ->
      Luv.File.Sync.rename ~from:"non_existent_file" ~to_:"foo"
      |> check_error_result "rename" `ENOENT
    end;

    "ftruncate: async", `Quick, begin fun () ->
      let buffer = Luv.Bigstring.from_string "open" in

      with_file_for_writing begin fun file ->
        Luv.File.Sync.write file [buffer]
        |> check_success_result "write"
        |> Unsigned.Size_t.to_int
        |> Alcotest.(check int) "bytes written" 4;

        Luv.File.Async.ftruncate file 3L (check_success_result "ftruncate");
        run ()
      end
    end;

    "ftruncate: sync", `Quick, begin fun () ->
      let buffer = Luv.Bigstring.from_string "open" in

      with_file_for_writing begin fun file ->
        Luv.File.Sync.write file [buffer]
        |> check_success_result "write"
        |> Unsigned.Size_t.to_int
        |> Alcotest.(check int) "bytes written" 4;

        Luv.File.Sync.ftruncate file 3L
        |> check_success_result "ftruncate"
      end
    end;

    "ftruncate failure: async", `Quick, begin fun () ->
      with_file_for_reading begin fun file ->
        let finished = ref false in

        Luv.File.Async.ftruncate file 0L begin fun result ->
          check_error_result "ftruncate" `EINVAL result;
          finished := true
        end;

        run ();
        Alcotest.(check bool) "finished" true !finished
      end
    end;

    "ftruncate failure: sync", `Quick, begin fun () ->
      with_file_for_reading begin fun file ->
        Luv.File.Sync.ftruncate file 0L
        |> check_error_result "ftruncate" `EINVAL
      end
    end;

    "copyfile: async", `Quick, begin fun () ->
      with_dummy_file begin fun path ->
        let to_ = path ^ ".copy" in

        Alcotest.(check bool) "original at start" true (Sys.file_exists path);
        Alcotest.(check bool) "new at start" false (Sys.file_exists to_);

        Luv.File.Async.copyfile path ~to_ (check_success_result "copyfile");
        run ();

        Alcotest.(check bool) "original at end" true (Sys.file_exists path);
        Alcotest.(check bool) "new at end" true (Sys.file_exists to_);

        Sys.remove to_
      end
    end;

    "copyfile: sync", `Quick, begin fun () ->
      with_dummy_file begin fun path ->
        let to_ = path ^ ".copy" in

        Alcotest.(check bool) "original at start" true (Sys.file_exists path);
        Alcotest.(check bool) "new at start" false (Sys.file_exists to_);

        Luv.File.Sync.copyfile path ~to_
        |> check_success_result "copyfile";

        Alcotest.(check bool) "original at end" true (Sys.file_exists path);
        Alcotest.(check bool) "new at end" true (Sys.file_exists to_);

        Sys.remove to_
      end
    end;

    "copyfile failure: async", `Quick, begin fun () ->
      let finished = ref false in

      Luv.File.Async.copyfile "non_existent_file" ~to_:"foo" begin fun result ->
        check_error_result "copyfile" `ENOENT result;
        finished := true
      end;

      run ();
      Alcotest.(check bool) "finished" true !finished
    end;

    "copyfile failure: sync", `Quick, begin fun () ->
      Luv.File.Sync.copyfile "non_existent_file" ~to_:"foo"
      |> check_error_result "copyfile" `ENOENT
    end;

    "sendfile: async", `Quick, begin fun () ->
      with_file_for_reading begin fun from ->
        with_file_for_writing begin fun to_ ->
          Luv.File.Async.sendfile
              ~to_ ~from ~offset:0L (Unsigned.Size_t.of_int 3)
              begin fun result ->

            check_success_result "sendfile" result
            |> Unsigned.Size_t.to_int
            |> Alcotest.(check int) "byte count" 3
          end;

          run ()
        end
      end
    end;

    "sendfile: sync", `Quick, begin fun () ->
      with_file_for_reading begin fun from ->
        with_file_for_writing begin fun to_ ->
          Luv.File.Sync.sendfile
            ~to_ ~from ~offset:0L (Unsigned.Size_t.of_int 3)
          |> check_success_result "sendfile"
          |> Unsigned.Size_t.to_int
          |> Alcotest.(check int) "byte count" 3
        end
      end
    end;

    "access: async", `Quick, begin fun () ->
      let finished = ref false in

      Luv.File.Async.access "file.ml" [`R_OK] begin fun result ->
        check_success_result "access" result;
        finished := true
      end;

      run ();
      Alcotest.(check bool) "finished" true !finished
    end;

    "access: sync", `Quick, begin fun () ->
      Luv.File.Sync.access "file.ml" [`R_OK]
      |> check_success_result "access"
    end;

    "access failure: async", `Quick, begin fun () ->
      let finished = ref false in

      Luv.File.Async.access "non_existent_file" [`R_OK] begin fun result ->
        check_error_result "access" `ENOENT result;
        finished := true
      end;

      run ();
      Alcotest.(check bool) "finished" true !finished
    end;

    "access failure: sync", `Quick, begin fun () ->
      Luv.File.Sync.access "non_existent_file" [`R_OK]
      |> check_error_result "access" `ENOENT
    end;
  ]
]
