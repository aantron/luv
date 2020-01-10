(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `Signal ] Handle.t

val init : ?loop:Loop.t -> unit -> (t, Error.t) Result.result
val start : t -> int -> (unit -> unit) -> (unit, Error.t) Result.result
val start_oneshot : t -> int -> (unit -> unit) -> (unit, Error.t) Result.result
val stop : t -> (unit, Error.t) Result.result
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
