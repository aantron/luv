type t = [ `Timer ] Handle.t

val init : ?loop:Loop.t -> unit -> (t, Error.t) Result.result

val start : ?repeat:int -> t -> int -> (t -> unit) -> Error.t
val stop : t -> Error.t
val again : t -> Error.t
val set_repeat : t -> int -> unit
val get_repeat : t -> Unsigned.UInt64.t

(* TODO Call update_time by default, as it is cheap on most systems. Document
   this. Offer a way not to do it. *)
