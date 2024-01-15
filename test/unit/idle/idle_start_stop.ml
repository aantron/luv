let () =
  Helpers.with_idle @@ fun idle ->

  let calls = ref 0 in
  Luv.Idle.start idle begin fun () ->
    print_endline "Idle";
    incr calls;
    if !calls >= 2 then
      Luv.Idle.stop idle |> ignore
  end
  |> ok "start" @@ fun () ->

  while Luv.Loop.run ~mode:`NOWAIT () do
    ()
  done;

  print_endline "Ok"
