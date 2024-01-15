let () =
  Helpers.with_prepare @@ fun prepare ->

  let calls = ref 0 in
  Luv.Prepare.start prepare begin fun () ->
    print_endline "Prepare";
    incr calls;
    if !calls >= 2 then
      Luv.Prepare.stop prepare |> ignore
  end
  |> ok "start" @@ fun () ->

  while Luv.Loop.run ~mode:`NOWAIT () do
    ()
  done;

  print_endline "Ok"
