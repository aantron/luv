type 'kind t = 'kind C.Types.Request.t Ctypes.ptr

(* TODO Test with a concrete type. *)
val cancel : _ t -> Error.t

(**/**)

val allocate :
  ?reference_count:int -> 'kind C.Types.Request.t Ctypes.typ -> 'kind t
(* TODO Is it necessary to pass the request to the callbacks? *)
val set_callback_1 : 'kind t -> ('kind t -> unit) -> unit
val set_callback_2 : 'kind t -> ('kind t -> _ -> unit) -> unit
val set_reference : ?index:int -> _ t -> _ -> unit
val release : _ t -> unit
