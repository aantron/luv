let with_idle f =
  Luv.Idle.init () |> ok "init" @@ fun idle ->
  f idle;
  Luv.Handle.close idle ignore

let with_check f =
  Luv.Check.init () |> ok "init" @@ fun check ->
  f check;
  Luv.Handle.close check ignore

let with_prepare f =
  Luv.Prepare.init () |> ok "init" @@ fun prepare ->
  f prepare;
  Luv.Handle.close prepare ignore
