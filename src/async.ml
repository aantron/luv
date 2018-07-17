type async = Luv_FFI.C.Types.Async.async
type t = async Handle.t

let trampoline =
  Luv_FFI.C.Functions.Async.get_trampoline ()

let init ?loop ~callback () =
  let async = Handle.allocate Luv_FFI.C.Types.Async.t in
  Handle.set_callback async callback;
  Luv_FFI.C.Functions.Async.init
    (Loop.or_default loop) (Handle.c async) trampoline
  |> Error.to_result async

let send async =
  Luv_FFI.C.Functions.Async.send (Handle.c async)
