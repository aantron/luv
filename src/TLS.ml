(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = C.Types.TLS.t Ctypes.ptr

let create () =
  let key = Ctypes.addr (Ctypes.make C.Types.TLS.t) in
  C.Functions.TLS.create key
  |> Error.to_result key

let delete =
  C.Functions.TLS.delete

let get key =
  Ctypes.raw_address_of_ptr (C.Functions.TLS.get key)

let set key value =
  C.Functions.TLS.set key (Ctypes.ptr_of_raw_address value)
