let () =
  Helpers.with_poll @@ fun poll ->

  Luv.Error.set_on_unhandled_exception (function
    | Exit -> print_endline "Ok"
    | _ -> ());

  Luv.Poll.start poll [`WRITABLE] begin fun _ ->
    Luv.Poll.stop poll |> ok "stop" @@ fun () ->
    raise Exit
  end;

  Luv.Loop.run () |> ignore
