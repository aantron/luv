let () =
  Helpers.with_check @@ fun check ->
  Luv.Error.set_on_unhandled_exception (function
    | Exit -> print_endline "Ok"
    | _ -> ());
  Luv.Check.start check (fun () -> raise Exit)
  |> ok "start" @@ fun () ->
  Luv.Loop.run ~mode:`NOWAIT () |> ignore
