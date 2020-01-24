(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = C.Types.Once.t Ctypes.ptr

let init () =
  let guard = Ctypes.addr (Ctypes.make C.Types.Once.t) in
  C.Functions.Once.init guard
  |> Error.to_result guard

let trampoline =
  C.Functions.Once.get_trampoline ()

external set_callback : (unit -> unit) -> unit = "luv_set_once_callback"

let once guard f =
  set_callback f;
  C.Functions.Once.once guard trampoline

let once_c guard f =
  C.Functions.Once.once guard (Ctypes.funptr_of_raw_address f)
