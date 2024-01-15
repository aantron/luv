let () =
  Helpers.with_idle @@ fun idle ->
  Luv.Error.set_on_unhandled_exception (function
    | Exit -> print_endline "Ok"
    | _ -> ());
  Luv.Idle.start idle (fun () -> raise Exit)
  |> ok "start" @@ fun () ->
  Luv.Loop.run ~mode:`NOWAIT () |> ignore
