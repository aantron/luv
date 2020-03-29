let () =
  let server = Luv.Pipe.init () |> Result.get_ok in
  ignore (Luv.Pipe.bind server "echo-pipe");

  Luv.Stream.listen server begin function
    | Error e ->
      Printf.eprintf "Listen error: %s\n" (Luv.Error.strerror e)
    | Ok () ->
      let client = Luv.Pipe.init () |> Result.get_ok in

      match Luv.Stream.accept ~server ~client with
      | Error _ ->
        Luv.Handle.close client ignore
      | Ok () ->

        Luv.Stream.read_start client begin function
          | Error `EOF ->
            Luv.Handle.close client ignore
          | Error e ->
            Printf.eprintf "Read error: %s\n" (Luv.Error.strerror e);
            Luv.Handle.close client ignore
          | Ok buffer ->
            Luv.Stream.write client [buffer] (fun _ -> ignore)
        end
  end;

  ignore (Luv.Loop.run () : bool)
