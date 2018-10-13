type 'kind t

val close : _ t -> unit
exception Handle_already_closed_this_is_a_programming_logic_error
(* DOC This is not raised by close, but by other functions. *)

val is_active : _ t -> bool
val is_closing : _ t -> bool

val ref : _ t -> unit
val unref : _ t -> unit
val has_ref : _ t -> bool

val get_loop : _ t -> Loop.t

(**/**)

val allocate :
  ?callback_count:int -> 'kind C.Types.Handle.t Ctypes.typ -> 'kind t
val c : 'kind t -> 'kind C.Types.Handle.t Ctypes.ptr
val set_callback : ?index:int -> _ t -> _ -> unit
val get_callback : index:int -> _ t -> _
val from_c : 'kind C.Types.Handle.t Ctypes.ptr -> 'kind t

(* DOC warn about memory leak if not calling close. *)
(* DOC after close, the loop must be run. *)
