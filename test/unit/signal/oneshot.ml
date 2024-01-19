let () =
  Helpers.with_signal @@ fun signal ->

  Luv.Signal.start_oneshot signal Luv.Signal.sighup (fun () ->
    print_endline "Signal")
  |> ok "start" @@ fun () ->

  Helpers.send_signal ();

  Luv.Loop.run () |> ignore;
  print_endline "Ok"
