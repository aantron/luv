type signal = Luv_FFI.C.Types.Signal.signal
type t = signal Handle.t

let init ?loop () =
  let signal = Handle.allocate Luv_FFI.C.Types.Signal.t in
  Luv_FFI.C.Functions.Signal.init (Loop.or_default loop) (Handle.c signal)
  |> Error.to_result signal

let trampoline =
  Luv_FFI.C.Functions.Signal.get_trampoline ()

let start ~callback signal ~signum =
  Handle.set_callback signal callback;
  Luv_FFI.C.Functions.Signal.start (Handle.c signal) trampoline signum

let start_oneshot ~callback signal ~signum =
  Handle.set_callback signal callback;
  Luv_FFI.C.Functions.Signal.start_oneshot (Handle.c signal) trampoline signum

let stop signal =
  Luv_FFI.C.Functions.Signal.stop (Handle.c signal)

let get_signum signal =
  Ctypes.getf (Ctypes.(!@) (Handle.c signal)) Luv_FFI.C.Types.Signal.signum
