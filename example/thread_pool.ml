let () =
  Luv.Thread_pool.queue_work (fun () ->
    Luv.Time.sleep 1000;
    print_endline "Finished")
    ignore;

  ignore (Luv.Loop.run ())
