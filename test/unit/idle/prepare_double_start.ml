let () =
  Helpers.with_prepare @@ fun prepare ->

  Luv.Prepare.start prepare (fun () -> print_endline "First")
  |> ok "first start" @@ fun () ->
  Luv.Prepare.start prepare (fun () -> print_endline "Second")
  |> ok "second start" @@ fun () ->

  Luv.Loop.run ~mode:`NOWAIT () |> ignore;
  Luv.Loop.run ~mode:`NOWAIT () |> ignore
