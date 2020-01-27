let () =
  let mutex = Luv.Mutex.init () |> Stdlib.Result.get_ok in
  Luv.Mutex.lock mutex;

  ignore @@ Luv.Thread.create begin fun () ->
    Luv.Time.sleep 1000;
    Luv.Mutex.unlock mutex
  end;

  Luv.Mutex.lock mutex;
  print_endline "Worker finished"
