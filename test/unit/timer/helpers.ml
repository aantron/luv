let with_timer f =
  Luv.Timer.init () |> ok "init" @@ fun timer ->
  f timer;
  Luv.Handle.close timer ignore
