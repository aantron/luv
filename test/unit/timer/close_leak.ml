(* Tests that close releases references to the callback. *)
let () =
  no_memory_leak begin fun _n ->
    Luv.Timer.init () |> ok "init" @@ fun timer ->
    Luv.Timer.start timer 0 ignore |> ok "start" @@ fun () ->
    Luv.Handle.close timer ignore;
    Luv.Loop.run () |> ignore
  end;
  print_endline "End"
