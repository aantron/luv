type t = [ `Poll ] Handle.t

type event = [
  | `Readable
  | `Writable
  | `Disconnect
  | `Prioritized
]

val init : ?loop:Loop.t -> fd:int -> unit -> (t, Error.t) Result.result
(* TODO Return type should be unit, just call the callback? *)
val start : t -> event list -> (t -> Error.t -> event list -> unit) -> Error.t
val stop : t -> Error.t
