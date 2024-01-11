let with_loop f =
  Luv.Loop.init () |> ok "init" @@ fun loop ->
  f loop;
  Luv.Loop.close loop |> ok "close" ignore
