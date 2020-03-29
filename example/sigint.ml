let () =
  let handle = Luv.Signal.init () |> Result.get_ok in

  ignore @@ Luv.Signal.start handle Luv.Signal.sigint begin fun () ->
    Luv.Handle.close handle ignore;
    print_endline "Exiting"
  end;

  print_endline "Type Ctrl+C to continue...";

  ignore (Luv.Loop.run () : bool)
