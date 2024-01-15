let () =
  Helpers.with_idle @@ fun idle ->

  Luv.Idle.start idle (fun () -> print_endline "First")
  |> ok "first start" @@ fun () ->
  Luv.Idle.start idle (fun () -> print_endline "Second")
  |> ok "second start" @@ fun () ->

  Luv.Loop.run ~mode:`NOWAIT () |> ignore;
  Luv.Loop.run ~mode:`NOWAIT () |> ignore
