(* TODO Signals may need some interfacing with OCaml signal handling. *)

type signal
type t = signal Handle.t

val init : ?loop:Loop.t -> unit -> (t, Error.Code.t) Result.result
val start : callback:(t -> int -> unit) -> t -> signum:int -> Error.Code.t
val start_oneshot :
  callback:(t -> int -> unit) -> t -> signum:int -> Error.Code.t
val stop : t -> Error.Code.t
val get_signum : t -> int
