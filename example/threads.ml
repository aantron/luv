let () =
  let track_length = 3 in

  let rec run_tortoise = function
    | 0 ->
      print_endline "Tortoise done running!"
    | n ->
      Luv.Time.sleep 2000;
      print_endline "Tortoise ran another step";
      run_tortoise (n - 1)
  in

  let rec run_hare = function
    | 0 ->
      print_endline "Hare done running!"
    | n ->
      Luv.Time.sleep 1000;
      print_endline "Hare ran another step";
      run_hare (n - 1)
  in

  let tortoise =
    Luv.Thread.create (fun () -> run_tortoise track_length)
    |> Stdlib.Result.get_ok
  in

  let hare =
    Luv.Thread.create (fun () -> run_hare track_length)
    |> Stdlib.Result.get_ok
  in

  ignore (Luv.Thread.join tortoise);
  ignore (Luv.Thread.join hare)
