let () =
  Luv.Async.init begin fun async ->
    print_endline "Async";
    Luv.Handle.close async ignore
  end
  |> ok "async init" @@ fun async ->

  Luv.Async.send async |> ok "send" @@ fun () ->

  Luv.Loop.run () |> ignore
