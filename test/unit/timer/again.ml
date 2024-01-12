(* Tests that the OCaml callback is not deallocated by stop. *)
let () =
  Helpers.with_timer @@ fun timer ->

  Luv.Timer.start timer 0 ~repeat:1 begin fun () ->
    Luv.Timer.stop timer
    |> ok "second stop" @@ fun () ->
    print_endline "Called"
  end
  |> ok "start" @@ fun () ->

  Luv.Timer.stop timer |> ok "first stop" @@ fun () ->
  Luv.Timer.again timer |> ok "again" @@ fun () ->

  Luv.Loop.run () |> ignore
