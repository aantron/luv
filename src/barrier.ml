(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = C.Types.Barrier.t Ctypes.ptr

let init count =
  let barrier = Ctypes.addr (Ctypes.make C.Types.Barrier.t) in
  C.Functions.Barrier.init barrier (Unsigned.UInt.of_int count)
  |> Error.to_result barrier

let destroy =
  C.Functions.Barrier.destroy

let wait =
  C.Blocking.Barrier.wait
