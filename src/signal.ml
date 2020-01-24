(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `Signal ] Handle.t

let init ?loop () =
  let signal = Handle.allocate C.Types.Signal.t in
  C.Functions.Signal.init (Loop.or_default loop) signal
  |> Error.to_result signal

let trampoline =
  C.Functions.Signal.get_trampoline ()

let start signal signum callback =
  Handle.set_reference signal (Error.catch_exceptions callback);
  C.Functions.Signal.start signal trampoline signum
  |> Error.to_result ()

let start_oneshot signal signum callback =
  Handle.set_reference signal (Error.catch_exceptions callback);
  C.Functions.Signal.start_oneshot signal trampoline signum
  |> Error.to_result ()

let stop signal =
  C.Functions.Signal.stop signal
  |> Error.to_result ()

let signum signal =
  Ctypes.getf (Ctypes.(!@) signal) C.Types.Signal.signum

include C.Types.Signal.Signum
