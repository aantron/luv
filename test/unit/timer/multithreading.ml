(* Rather than testing timers, this test uses timers to test that Luv.Loop.run
   releases the runtime lock. So, in a sense, it is primarily a loop test. *)
let () =
  Helpers.with_timer @@ fun timer ->

  let start_time = Unix.gettimeofday () in

  Luv.Timer.start timer 200 ignore
  |> ok "start" @@ fun () ->

  ignore @@ Thread.create (fun () -> print_endline "Worker thread") ();

  print_endline "Main thread";
  Luv.Loop.run () |> ignore;
  let elapsed = Unix.gettimeofday () -. start_time in

  Printf.printf "%b\n" (elapsed < 0.5)
