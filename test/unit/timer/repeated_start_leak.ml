let () =
  Helpers.with_timer @@ fun timer ->
  no_memory_leak (fun _n ->
    Luv.Timer.start timer 1 (fresh_callback ()) |> ok "start" @@ ignore);
  print_endline "End"
