let () =
  let redirect = Luv.Process.[
    inherit_fd ~fd:stdout ~from_parent_fd:stdout ()
  ]
  in
  ignore (Luv.Process.spawn ~redirect "echo" ["echo"; "Hello,"; "world!"]);
  ignore (Luv.Loop.run ())
