open Imports

type poll
type t = poll Handle.t

type event = [
  | `Readable
  | `Writable
  | `Disconnect
  | `Prioritized
]

val init : ?loop:Loop.t ptr -> fd:int -> unit -> (t, Error.Code.t) result
val start :
  callback:(t -> Error.Code.t -> event list -> unit) ->
  t ->
  event list ->
    Error.Code.t
val stop : t -> Error.Code.t
