let () =
  Helpers.with_check @@ fun check ->

  Luv.Check.start check (fun () -> print_endline "First")
  |> ok "first start" @@ fun () ->
  Luv.Check.start check (fun () -> print_endline "Second")
  |> ok "second start" @@ fun () ->

  Luv.Loop.run ~mode:`NOWAIT () |> ignore;
  Luv.Loop.run ~mode:`NOWAIT () |> ignore
