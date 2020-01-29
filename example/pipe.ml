let () =
  let pipe = Luv.Pipe.init () |> Stdlib.Result.get_ok in

  let redirect = Luv.Process.[
    to_parent_pipe ~fd:stdout ~parent_pipe:pipe ()
  ]
  in
  ignore (Luv.Process.spawn ~redirect "echo" ["echo"; "Hello,"; "world!"]);

  Luv.Stream.read_start pipe begin function
    | Error `EOF ->
      Luv.Handle.close pipe ignore;
    | Error e ->
      Printf.eprintf "Read error: %s\n" (Luv.Error.strerror e);
      Luv.Handle.close pipe ignore
    | Ok buffer ->
      print_string (Luv.Buffer.to_string buffer)
  end;

  ignore (Luv.Loop.run ())
