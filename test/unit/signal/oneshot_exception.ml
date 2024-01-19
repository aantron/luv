let () =
  Helpers.with_signal @@ fun signal ->

  Luv.Error.set_on_unhandled_exception (function
    | Exit -> print_endline "Ok"
    | _ -> ());

  Luv.Signal.start_oneshot signal Luv.Signal.sighup (fun () -> raise Exit)
  |> ok "start" @@ fun () ->

  Helpers.send_signal ();

  Luv.Loop.run () |> ignore
