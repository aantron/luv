let () =
  Luv.Async.init ignore |> ok "init" @@ fun async ->
  Luv.Handle.close async ignore;
  print_endline "Ok"
