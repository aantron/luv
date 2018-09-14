type async
type t = async Handle.t

val init :
  ?loop:Loop.t -> callback:(t -> unit) -> unit ->
    (t, Error.Code.t) Result.result
val send : t -> Error.Code.t
