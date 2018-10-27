type t = [ `Signal ] Handle.t

val init : ?loop:Loop.t -> unit -> (t, Error.t) Result.result
val start : callback:(t -> int -> unit) -> t -> signum:int -> Error.t
val start_oneshot : callback:(t -> int -> unit) -> t -> signum:int -> Error.t
val stop : t -> Error.t
val get_signum : t -> int

(* TODO Bind some signals *)
