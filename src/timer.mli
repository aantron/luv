open Imports

type timer
type t = timer Handle.t

val init : ?loop:Loop.t ptr -> unit -> (t, Error.Code.t) result

val start :
  callback:(t -> unit) -> t -> timeout:int -> repeat:int -> Error.Code.t

val stop : t -> Error.Code.t
val again : t -> Error.Code.t
val set_repeat : t -> int -> unit
val get_repeat : t -> Unsigned.UInt64.t

(* TODO docs: Note about using Luv.Handle.close. *)
(* TODO test more of the ops after close. *)
