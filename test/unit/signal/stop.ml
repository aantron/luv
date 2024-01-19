let () =
  Helpers.with_signal @@ fun signal ->

  Luv.Signal.start signal Luv.Signal.sighup (fun () ->
    Luv.Signal.stop signal |> ok "stop" ignore)
  |> ok "start" @@ fun () ->

  Helpers.send_signal ();

  Luv.Loop.run () |> ignore;
  print_endline "Ok"
