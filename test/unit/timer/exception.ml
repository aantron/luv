(* Checks that exceptions raised in loop callbacks don't leak into the loop's
   stack frame, but go to the unhandled exception handler. *)
let () =
  Helpers.with_timer @@ fun timer ->
  Luv.Error.set_on_unhandled_exception (function
    | Exit -> print_endline "Ok"
    | _ -> ());
  Luv.Timer.start timer 0 (fun () -> raise Exit)
  |> ok "start" @@ fun () ->
  Luv.Loop.run () |> ignore
