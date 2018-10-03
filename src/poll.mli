type t = [ `Poll ] Handle.t

type event = [
  | `Readable
  | `Writable
  | `Disconnect
  | `Prioritized
]

val init : ?loop:Loop.t -> fd:int -> unit -> (t, Error.t) Result.result
val start :
  callback:(t -> Error.t -> event list -> unit) -> t -> event list -> Error.t
val stop : t -> Error.t
