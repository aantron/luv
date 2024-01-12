(* Checks is_active for handles in general. This isn't specifically a timer
   test. Timers are just one of the simplest kinds of handle. *)
let () =
  Helpers.with_timer @@ fun timer ->
  Printf.printf "%b\n" (Luv.Handle.is_active timer);
  Luv.Timer.start timer 0 ignore |> ok "start" @@ fun () ->
  Printf.printf "%b\n" (Luv.Handle.is_active timer)
