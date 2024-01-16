let () =
  Luv.Async.init begin fun async ->
    print_endline "Async";
    Luv.Handle.close async ignore
  end
  |> ok "async init" @@ fun async ->

  ignore @@ Thread.create begin fun () ->
    Unix.sleepf 0.2;
    Luv.Async.send async |> ignore
  end ();

  Luv.Loop.run () |> ignore
