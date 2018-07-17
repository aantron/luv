let fail error_code =
  raise (Failure (Luv.Error.strerror error_code))

let check error_code =
  if error_code <> Luv.Error.Code.success then
    fail error_code

let () =
  let timer =
    match Luv.Timer.init () with
    | Ok timer -> timer
    | Error error_code -> fail error_code
  in

  print_endline "Delaying for one second...";

  Luv.Loop.(update_time (default ()));
  check @@ Luv.Timer.start timer ~timeout:1000 ~repeat:0
      ~callback:begin fun _ ->
    print_endline "Done"
  end;

  ignore @@ Luv.Loop.(run (default ()) Run_mode.default)
