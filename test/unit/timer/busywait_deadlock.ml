(* Runs Luv.Loop.run in nowait mode. If calling Loop.run this way does not
   release the runtime lock, even though the call is non-blocking, when the
   callback tries to acquire the lock, there will be a deadlock. *)
let () =
  Helpers.with_timer @@ fun timer ->
  Luv.Timer.start timer 10 (fun () -> print_endline "Ok")
  |> ok "start" @@ fun () ->
  Unix.sleep 1;
  Luv.Loop.run ~mode:`NOWAIT () |> ignore
