let with_signal f =
  Luv.Signal.init () |> ok "init" @@ fun signal ->
  f signal;
  Luv.Handle.close signal ignore

let send_signal () =
  Unix.kill (Unix.getpid ()) Sys.sighup
