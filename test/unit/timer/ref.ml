(* Checks reference status for handles in general. This isn't specifically a
   timer test. Timers are just one of the simplest kinds of handle. *)
let () =
  Helpers.with_timer @@ fun timer ->
  Printf.printf "%b\n" (Luv.Handle.has_ref timer);
  Luv.Handle.ref timer;
  Printf.printf "%b\n" (Luv.Handle.has_ref timer);
  Luv.Handle.unref timer;
  Printf.printf "%b\n" (Luv.Handle.has_ref timer);
  Luv.Handle.unref timer;
  Printf.printf "%b\n" (Luv.Handle.has_ref timer)
