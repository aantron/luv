(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type 'kind t = 'kind C.Types.Request.t Ctypes.ptr

(* TODO Test with a concrete type. *)
val cancel :
  [< `File | `Getaddrinfo | `Getnameinfo | `Work ] t -> (unit, Error.t) result

(**/**)

val allocate :
  ?reference_count:int -> 'kind C.Types.Request.t Ctypes.typ -> 'kind t
val set_callback : _ t -> (_ -> unit) -> unit
val set_reference : ?index:int -> _ t -> _ -> unit
val release : _ t -> unit
