type t = [ `Async ] Handle.t

let trampoline =
  C.Functions.Async.get_trampoline ()

let init ?loop ~callback () =
  let async = Handle.allocate C.Types.Async.t in
  Handle.set_callback async callback;
  C.Functions.Async.init (Loop.or_default loop) (Handle.c async) trampoline
  |> Error.to_result async

let send async =
  C.Functions.Async.send (Handle.c async)
