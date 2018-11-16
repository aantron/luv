type 'kind t = 'kind C.Types.Request.t Ctypes.ptr

(* TODO Test with a concrete type. *)
val cancel : [< `File | `Getaddrinfo | `Getnameinfo | `Work ] t -> Error.t

(**/**)

val allocate :
  ?reference_count:int -> 'kind C.Types.Request.t Ctypes.typ -> 'kind t
val set_callback : _ t -> (_ -> unit) -> unit
val set_reference : ?index:int -> _ t -> _ -> unit
val release : _ t -> unit
