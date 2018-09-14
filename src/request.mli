(* TODO Hide? *)
(* module Type :
sig
  type t = private int
  val req : t
  val connect : t
  val write : t
  val shutdown : t
  val udp_send : t
  val fs : t
  val work : t
  val getaddrinfo : t
  val getnameinfo : t
end *)

(* type base_request *)
(* type 'type_ t = 'type_ Luv_FFI.C.Types.Request.t ptr *)
type 'type_ t

(* val t : base_request t Ctypes.typ *)

(* TODO Test with a concrete type. *)
val cancel : _ t -> Error.Code.t

exception Request_object_reused_this_is_a_programming_error

(* val size : Type.t -> Unsigned.size_t *)
(* TODO Test all request types' size. *)

(* TODO Test data on a generic request. *)
(* val get_data : 'any_request_type t ptr -> unit ptr *)
(* val set_data : 'any_request_type t ptr -> unit ptr -> unit *)

(* TODO Test type name on a specific request. *)
(* val get_type : 'any_request_type t ptr -> Type.t *)

(* val type_name : Type.t -> string *)

(* TODO Internal *)

(* TODO Note that after a request is allocated, it must be used for the memory
   to be cleared. *)
val allocate : 'type_ Luv_FFI.C.Types.Request.t Ctypes.typ -> 'type_ t
val c : 'type_ t -> 'type_ Luv_FFI.C.Types.Request.t Ctypes.ptr
val set_callback : 'type_ t -> ('type_ t -> Error.Code.t -> unit) -> unit
val finished : _ t -> unit
