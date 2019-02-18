let () =
  Luv.Loop.(update_time (default ()));
  print_endline "Depending on luv works."
