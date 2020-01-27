let () =
  let progress = ref 0. in
  let show_progress () =
    Printf.printf "%i%%\n%!" (int_of_float (!progress *. 100.)) in

  let notification =
    Luv.Async.init (fun _ -> show_progress ()) |> Stdlib.Result.get_ok in

  let rec do_work total n =
    if n >= total then
      ()
    else begin
      Luv.Time.sleep 1000;
      progress := float_of_int (n + 1) /. float_of_int total;
      ignore (Luv.Async.send notification);
      do_work total (n + 1)
    end
  in

  let finished _ =
    Luv.Handle.close notification ignore;
    print_endline "Done"
  in

  Luv.Thread_pool.queue_work (fun () -> do_work 3 0) finished;

  ignore (Luv.Loop.run ())
