(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = C.Types.Semaphore.t Ctypes.ptr

let init count =
  let semaphore = Ctypes.addr (Ctypes.make C.Types.Semaphore.t) in
  C.Functions.Semaphore.init semaphore (Unsigned.UInt.of_int count)
  |> Error.to_result semaphore

let destroy =
  C.Functions.Semaphore.destroy

let post =
  C.Functions.Semaphore.post

let wait =
  C.Blocking.Semaphore.wait

let trywait semaphore =
  C.Functions.Semaphore.trywait semaphore
  |> Error.to_result ()
