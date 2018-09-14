(* TODO Inspect all uses for whether they return an option or not. It should
   only be an issue in pipe_pending_type. *)
(* TODO Document that unknown is implemented as t option. *)
(* module Type :
sig
  type t = private int
  val async : t
  val check : t
  val fs_event : t
  val fs_poll : t
  val handle : t
  val idle : t
  val named_pipe : t
  val poll : t
  val prepare : t
  val process : t
  val stream : t
  val tcp : t
  val timer : t
  val tty : t
  val udp : t
  val signal : t
  val file : t
end *)

(* val send_buffer_size : 'any_type_of_handle t ptr -> int ptr -> Error.Code.t
val recv_buffer_size : 'any_type_of_handle t ptr -> int ptr -> Error.Code.t *)
(* TODO Test these after the right handle type is bound. *)

(* TODO Test, especially once the right kind of handle becomes available. *)
(* val fileno : 'any_type_of_handle t ptr -> Misc.Os_fd.t ptr -> Error.Code.t *)

(* TODO Test *)
(* val walk :
  Loop.t ptr -> (base_handle t ptr -> unit ptr -> unit) -> unit ptr -> unit *)
(* TODO Bind this again, and create some kind of up-cast. *)

(* val get_type : 'any_type_of_handle t ptr -> Type.t *)
(* val type_name : Type.t -> string *)

(* TODO Use a polymorphic variant to contrain the handle kinds even more
   usefully? But will it be worth it? It will probably require an upcast to
   be truly useful. *)

(* TODO Note in docs that other kinds of handles can just be passed in. *)

type 'type_ t

val close : _ t -> unit
exception Handle_already_closed_this_is_a_programming_logic_error
(* TODO Is this exception ever raised? *)
(* TODO Doc: if exception is not raise, note that close can be called multiple
   times. *)

val is_active : _ t -> bool
val is_closing : _ t -> bool

val ref : _ t -> unit
val unref : _ t -> unit
val has_ref : _ t -> bool

val get_loop : _ t -> Loop.t

(* TODO Internal *)

val allocate :
  ?callback_count:int -> 'type_ Luv_FFI.C.Types.Handle.t Ctypes.typ -> 'type_ t
val c : 'type_ t -> 'type_ Luv_FFI.C.Types.Handle.t Ctypes.ptr
(* TODO Make the index required. *)
val set_callback : ?index:int -> 'type_ t -> _ -> unit
val get_callback : index:int -> 'type_ t -> _
val from_c : 'type_ Luv_FFI.C.Types.Handle.t Ctypes.ptr -> 'type_ t

(* TODO docs warn about memory leak if not calling close. *)
(* TODO docs after close, the loop must be run. *)
