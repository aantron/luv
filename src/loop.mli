(* TODO Document with an example how to take address for use in functions. *)
(* TODO Also send people to the test cases. *)
(* TODO Example on how to allocate a loop. *)
(* TODO Sort and clean up. *)
(* TODO Async exception handling. Test it as well. *)

type t = Luv_FFI.C.Types.Loop.t Ctypes.ptr

val init : unit -> (t, Error.Code.t) Result.result

module Option :
sig
  type 'value t = private int
  val block_signal : int t
  val sigprof : int
end

val configure : t -> 'value Option.t -> 'value -> Error.Code.t

val close : t -> Error.Code.t
val default : unit -> t

module Run_mode :
sig
  type t = private int
  val default : t
  val once : t
  val nowait : t
end

(* TODO Make both arguments optional? *)
val run : t -> Run_mode.t -> bool
val alive : t -> bool
val stop : t -> unit
val size : unit -> Unsigned.size_t
val backend_fd : t -> int
val backend_timeout : t -> int
val now : t -> Unsigned.UInt64.t
val update_time : t -> unit

(* TODO Note that walk is implemented in Luv.Handle.walk. *)

val fork : t -> Error.Code.t

(* TODO Hide these? *)
val get_data : t -> unit Ctypes.ptr
val set_data : t -> unit Ctypes.ptr -> unit

(* TODO Internal *)

val or_default : t option -> t
