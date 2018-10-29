type t = [ `Timer ] Handle.t

val init : ?loop:Loop.t -> unit -> (t, Error.t) Result.result
val start :
  ?call_update_time:bool -> ?repeat:int -> t -> int -> (unit -> unit) -> Error.t
val stop : t -> Error.t
val again : t -> Error.t
val set_repeat : t -> int -> unit
val get_repeat : t -> int
