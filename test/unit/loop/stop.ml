let () =
  Helpers.with_loop @@ fun loop ->
  Luv.Loop.stop loop;
  print_endline "Ok"
