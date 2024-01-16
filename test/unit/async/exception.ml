let () =
  Luv.Async.init (fun _async -> raise Exit)
  |> ok "async init" @@ fun async ->

  Luv.Error.set_on_unhandled_exception begin function
    | Exit ->
      print_endline "Exception";
      Luv.Handle.close async ignore
    | _ ->
      ()
  end;

  Luv.Async.send async |> ok "send" @@ fun () ->

  Luv.Loop.run () |> ignore;

  print_endline "Ok"
