let () =
  Helpers.with_prepare @@ fun prepare ->
  Luv.Error.set_on_unhandled_exception (function
    | Exit -> print_endline "Ok"
    | _ -> ());
  Luv.Prepare.start prepare (fun () -> raise Exit)
  |> ok "start" @@ fun () ->
  Luv.Loop.run ~mode:`NOWAIT () |> ignore
