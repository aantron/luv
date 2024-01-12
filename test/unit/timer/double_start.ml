let () =
  Helpers.with_timer @@ fun timer ->

  Luv.Timer.start timer 1 (fun () -> print_endline "First")
  |> ok "first start" @@ fun () ->
  Luv.Timer.start timer 1 (fun () -> print_endline "Second")
  |> ok "second start" @@ fun () ->

  Luv.Loop.run () |> ignore
