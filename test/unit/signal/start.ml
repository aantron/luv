let () =
  Helpers.with_signal @@ fun signal ->

  Luv.Signal.start signal Luv.Signal.sighup (fun () ->
    print_endline "Ok";
    exit 0)
  |> ok "start" @@ fun () ->

  Helpers.send_signal ();

  Luv.Loop.run () |> ignore
