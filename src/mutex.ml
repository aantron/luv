(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = C.Types.Mutex.t Ctypes.ptr

let init ?(recursive = false) () =
  let mutex = Ctypes.addr (Ctypes.make C.Types.Mutex.t) in
  let result =
    if recursive then
      C.Functions.Mutex.init_recursive mutex
    else
      C.Functions.Mutex.init mutex
  in
  Error.to_result mutex result

let destroy =
  C.Functions.Mutex.destroy

let lock =
  C.Blocking.Mutex.lock

let trylock mutex =
  C.Functions.Mutex.trylock mutex
  |> Error.to_result ()

let unlock =
  C.Functions.Mutex.unlock
