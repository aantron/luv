let () =
  let pipe = Luv.Pipe.init () |> Result.get_ok in
  Luv.Pipe.open_ pipe Luv.File.stdout |> Result.get_ok;

  Luv.Stream.write pipe [Luv.Buffer.from_string "Hello, world!\n"]
    (fun _ _ -> ());

  ignore (Luv.Loop.run () : bool)
