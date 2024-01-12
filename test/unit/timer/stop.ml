let () =
  Helpers.with_timer @@ fun timer ->

  Luv.Timer.start timer 0 (fun () -> print_endline "Called")
  |> ok "start" @@ fun () ->

  Luv.Timer.stop timer |> ok "stop" @@ fun () ->

  Luv.Loop.run () |> ignore;

  print_endline "Ok"
