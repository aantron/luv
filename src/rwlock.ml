(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = C.Types.Rwlock.t Ctypes.ptr

let init () =
  let rwlock = Ctypes.addr (Ctypes.make C.Types.Rwlock.t) in
  C.Functions.Rwlock.init rwlock
  |> Error.to_result rwlock

let destroy =
  C.Functions.Rwlock.destroy

let rdlock =
  C.Blocking.Rwlock.rdlock

let tryrdlock rwlock =
  C.Functions.Rwlock.tryrdlock rwlock
  |> Error.to_result ()

let rdunlock =
  C.Functions.Rwlock.rdunlock

let wrlock =
  C.Blocking.Rwlock.wrlock

let trywrlock rwlock =
  C.Functions.Rwlock.trywrlock rwlock
  |> Error.to_result ()

let wrunlock =
  C.Functions.Rwlock.wrunlock
