open Imports

type async
type t = async Handle.t

val init :
  ?loop:Loop.t ptr -> callback:(t -> unit) -> unit -> (t, Error.Code.t) result
val send : t -> Error.Code.t
