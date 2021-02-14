let () =
  Luv.File.(write stdout [Luv.Buffer.from_string "Hello, world!\n"]) ignore;
  ignore (Luv.Loop.run () : bool)
