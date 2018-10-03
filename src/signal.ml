type t = [ `Signal ] Handle.t

let init ?loop () =
  let signal = Handle.allocate C.Types.Signal.t in
  C.Functions.Signal.init (Loop.or_default loop) (Handle.c signal)
  |> Error.to_result signal

let trampoline =
  C.Functions.Signal.get_trampoline ()

let start ~callback signal ~signum =
  Handle.set_callback signal callback;
  C.Functions.Signal.start (Handle.c signal) trampoline signum

let start_oneshot ~callback signal ~signum =
  Handle.set_callback signal callback;
  C.Functions.Signal.start_oneshot (Handle.c signal) trampoline signum

let stop signal =
  C.Functions.Signal.stop (Handle.c signal)

let get_signum signal =
  Ctypes.getf (Ctypes.(!@) (Handle.c signal)) C.Types.Signal.signum
