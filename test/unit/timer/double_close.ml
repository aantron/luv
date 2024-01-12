(* Tests that close releases references to the callback. *)
let () =
  Luv.Timer.init () |> ok "init" @@ fun timer ->
  Luv.Handle.close timer ignore;
  Luv.Loop.run () |> ignore;
  Gc.full_major ();
  Luv.Handle.close timer ignore;
  Luv.Loop.run () |> ignore;
  print_endline "End"
