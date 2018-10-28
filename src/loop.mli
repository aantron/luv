type t = C.Types.Loop.t Ctypes.ptr

val init : unit -> (t, Error.t) Result.result

module Option :
sig
  type 'value t = private int
  val block_signal : int t
  val sigprof : int
end

val configure : t -> 'value Option.t -> 'value -> Error.t

val close : t -> Error.t
val default : unit -> t

module Run_mode :
sig
  type t = private int
  val default : t
  val once : t
  val nowait : t
end

val run : t -> Run_mode.t -> bool
val alive : t -> bool
val stop : t -> unit
val size : unit -> Unsigned.size_t
val backend_fd : t -> int
val backend_timeout : t -> int
val now : t -> Unsigned.UInt64.t
val update_time : t -> unit

val fork : t -> Error.t

val get_data : t -> unit Ctypes.ptr
val set_data : t -> unit Ctypes.ptr -> unit

(**/**)

val or_default : t option -> t
