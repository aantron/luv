type t = [ `Idle ] Handle.t

val init : ?loop:Loop.t -> unit -> (t, Error.t) Result.result
val start : callback:(t -> unit) -> t -> Error.t
val stop : t -> Error.t
