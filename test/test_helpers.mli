open Luv.Imports

val check_success : string -> Luv.Error.Code.t -> unit
val check_error_code : string -> Luv.Error.Code.t -> Luv.Error.Code.t -> unit

val check_success_result : string -> ('a, Luv.Error.Code.t) result -> 'a

val check_not_null : string -> _ Ctypes.ptr -> unit
val check_pointer : string -> 'a Ctypes.ptr -> 'a Ctypes.ptr -> unit

(* val check_handle_type : Luv.Handle.Type.t -> Luv.Handle.Type.t -> unit *)

val make_callback : unit -> ('a -> unit)
val no_memory_leak : ?base_repetitions:int -> (int -> unit) -> unit

val default_loop : Luv.Loop.t Ctypes.ptr
val run : unit -> unit

val port : unit -> int
