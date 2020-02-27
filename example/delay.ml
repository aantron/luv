let () =
  let timer = Luv.Timer.init () |> Result.get_ok in

  ignore (Luv.Timer.start timer 1000 (fun () ->
    print_endline "Hello, world!"));

  print_endline "Waiting...";
  ignore (Luv.Loop.run ())
