(* TODO Document with an example how to take address for use in functions. *)
(* TODO Also send people to the test cases. *)
(* TODO Example on how to allocate a loop. *)
(* TODO Sort and clean up. *)
(* TODO Async exception handling. Test it as well. *)
(* TODO Hide the Ctypes-ness of this module. *)

open Imports

type t = Luv_FFI.C.Types.Loop.t

(* TODO Combine allocate-init. *)
val t : t Ctypes.typ
val allocate : unit -> t ptr

val init : t ptr -> Error.Code.t

module Option :
sig
  type 'value t = private int
  val block_signal : int t
  val sigprof : int
end

val configure : t ptr -> 'value Option.t -> 'value -> Error.Code.t

val close : t ptr -> Error.Code.t
val default : unit -> t ptr

module Run_mode :
sig
  type t = private int
  val default : t
  val once : t
  val nowait : t
end

(* TODO Make both arguments optional? *)
val run : t ptr -> Run_mode.t -> bool
val alive : t ptr -> bool
val stop : t ptr -> unit
val size : unit -> Unsigned.size_t
val backend_fd : t ptr -> int
val backend_timeout : t ptr -> int
val now : t ptr -> Unsigned.UInt64.t
val update_time : t ptr -> unit

(* TODO Note that walk is implemented in Luv.Handle.walk. *)

val fork : t ptr -> Error.Code.t

val get_data : t ptr -> unit ptr
val set_data : t ptr -> unit ptr -> unit

(* TODO Internal *)

val or_default : t ptr option -> t ptr
