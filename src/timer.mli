type t = [ `Timer ] Handle.t

val init : ?loop:Loop.t -> unit -> (t, Error.t) Result.result

(* TODO Make repeat optional, and put callback last. *)
val start :
  callback:(t -> unit) -> t -> timeout:int -> repeat:int -> Error.t

val stop : t -> Error.t
val again : t -> Error.t
val set_repeat : t -> int -> unit
val get_repeat : t -> Unsigned.UInt64.t

(* TODO test more of the ops after close. *)
