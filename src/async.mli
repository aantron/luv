type t = [ `Async ] Handle.t

val init :
  ?loop:Loop.t -> callback:(t -> unit) -> unit -> (t, Error.t) Result.result
val send : t -> Error.t
