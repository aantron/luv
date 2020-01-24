(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = C.Types.Condition.t Ctypes.ptr

let init () =
  let condition = Ctypes.addr (Ctypes.make C.Types.Condition.t) in
  C.Functions.Condition.init condition
  |> Error.to_result condition

let destroy =
  C.Functions.Condition.destroy

let signal =
  C.Functions.Condition.signal

let broadcast =
  C.Functions.Condition.broadcast

let wait =
  C.Blocking.Condition.wait

let timedwait condition mutex interval =
  C.Blocking.Condition.timedwait
    condition mutex (Unsigned.UInt64.of_int interval)
  |> Error.to_result ()
