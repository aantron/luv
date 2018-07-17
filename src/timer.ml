type timer = Luv_FFI.C.Types.Timer.timer
type t = timer Handle.t

let init ?loop () =
  let timer = Handle.allocate Luv_FFI.C.Types.Timer.t in
  Luv_FFI.C.Functions.Timer.init (Loop.or_default loop) (Handle.c timer)
  |> Error.to_result timer

let trampoline =
  Luv_FFI.C.Functions.Timer.get_trampoline ()

let start ~callback timer ~timeout ~repeat =
  Handle.set_callback timer callback;

  Luv_FFI.C.Functions.Timer.start
    (Handle.c timer)
    trampoline
    (Unsigned.UInt64.of_int timeout)
    (Unsigned.UInt64.of_int repeat)

let stop timer =
  Luv_FFI.C.Functions.Timer.stop (Handle.c timer)

let again timer =
  Luv_FFI.C.Functions.Timer.again (Handle.c timer)

let set_repeat timer repeat =
  Luv_FFI.C.Functions.Timer.set_repeat
    (Handle.c timer) (Unsigned.UInt64.of_int repeat)

let get_repeat timer =
  Luv_FFI.C.Functions.Timer.get_repeat (Handle.c timer)
