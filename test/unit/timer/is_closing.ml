(* Checks is_closing for handles in general. This isn't specifically a timer
   test. Timers are just one of the simplest kinds of handle. *)
let () =
  Helpers.with_timer @@ fun timer ->
  Printf.printf "%b\n" (Luv.Handle.is_closing timer);
  Luv.Handle.close timer ignore;
  Printf.printf "%b\n" (Luv.Handle.is_closing timer);
  Luv.Loop.run () |> ignore;
  Printf.printf "%b\n" (Luv.Handle.is_closing timer)
