type 'kind t = 'kind C.Types.Request.t Ctypes.ptr

(* TODO Test with a concrete type. *)
val cancel : _ t -> Error.t

(**/**)

val allocate : 'kind C.Types.Request.t Ctypes.typ -> 'kind t
val c : 'kind t -> 'kind C.Types.Request.t Ctypes.ptr
val set_callback_1 : 'kind t -> ('kind t -> unit) -> unit
val set_callback_2 : 'kind t -> ('kind t -> _ -> unit) -> unit
val clear_callback : _ t -> unit
