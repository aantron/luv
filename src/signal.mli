type t = [ `Signal ] Handle.t

val init : ?loop:Loop.t -> unit -> (t, Error.t) Result.result
val start : t -> int -> (t -> int -> unit) -> Error.t
val start_oneshot : t -> int -> (t -> int -> unit) -> Error.t
val stop : t -> Error.t
val get_signum : t -> int

(* DOC Explain why these signals are bound specifically: there is emulation on
   Windows. *)
(* DOC Document that the signal numbers are not the ones in module Sys. *)
val sigabrt : int
val sigfpe : int
val sighup : int
val sigill : int
val sigint : int
val sigkill : int
val sigsegv : int
val sigterm : int
val sigwinch : int
