type 'kind t = 'kind C.Types.Request.t Ctypes.ptr

(* TODO Test with a concrete type. *)
val cancel : _ t -> Error.t

(**/**)

val allocate : 'kind C.Types.Request.t Ctypes.typ -> 'kind t
val c : 'kind t -> 'kind C.Types.Request.t Ctypes.ptr
(* TODO Is it necessary to pass the request? Or is it always retained? *)
val set_callback_1 : 'kind t -> ('kind t -> unit) -> unit
val set_callback_2 : 'kind t -> ('kind t -> _ -> unit) -> unit
(* TODO Remove *)
val clear_callback_if_not_started : _ t -> _ option -> Error.t -> Error.t
val clear_callback : _ t -> unit
