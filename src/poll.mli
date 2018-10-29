type t = [ `Poll ] Handle.t

module Event :
sig
  type t

  val readable : t
  val writable : t
  val disconnect : t
  val prioritized : t

  val (lor) : t -> t -> t
  val list : t list -> t
  val test : t -> t -> bool
end

val init : ?loop:Loop.t -> int -> (t, Error.t) Result.result
val init_socket : ?loop:Loop.t -> Misc.Os_socket.t -> (t, Error.t) Result.result
val start : t -> Event.t -> ((Event.t, Error.t) Result.result -> unit) -> unit
val stop : t -> Error.t
