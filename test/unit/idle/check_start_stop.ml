let () =
  Helpers.with_check @@ fun check ->

  let calls = ref 0 in
  Luv.Check.start check begin fun () ->
    print_endline "Check";
    incr calls;
    if !calls >= 2 then
      Luv.Check.stop check |> ignore
  end
  |> ok "start" @@ fun () ->

  while Luv.Loop.run ~mode:`NOWAIT () do
    ()
  done;

  print_endline "Ok"
