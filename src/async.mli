type t = [ `Async ] Handle.t

val init : ?loop:Loop.t -> (t -> unit) -> (t, Error.t) Result.result
val send : t -> Error.t
