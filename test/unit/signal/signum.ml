let () =
  Helpers.with_signal @@ fun signal ->

  Luv.Signal.start signal Luv.Signal.sighup ignore
  |> ok "start" @@ fun () ->

  Printf.printf "%b\n" (Luv.Signal.signum signal = Luv.Signal.sighup)
