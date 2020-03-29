let () =
  let child =
    Luv.Process.spawn "sleep" ["sleep"; "10"] |> Result.get_ok in

  ignore (Luv.Process.kill child Luv.Signal.sigkill);

  ignore (Luv.Loop.run () : bool)
