let () =
  let idle = Luv.Idle.init () |> Result.get_ok in

  let counter = ref 0 in

  ignore @@ Luv.Idle.start idle begin fun () ->
    counter := !counter + 1;
    print_endline "Loop iteration";

    if !counter >= 10 then
      ignore (Luv.Idle.stop idle)
  end;

  ignore (Luv.Loop.run ())
