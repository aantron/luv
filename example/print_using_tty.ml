let () =
  let tty = Luv.TTY.init Luv.File.stdout |> Result.get_ok in

  Luv.Stream.write tty [Luv.Buffer.from_string "Hello, world!\n"]
    (fun _ _ -> ());

  ignore (Luv.Loop.run () : bool)
