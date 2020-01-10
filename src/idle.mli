(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `Idle ] Handle.t

val init : ?loop:Loop.t -> unit -> (t, Error.t) Result.result
val start : t -> (unit -> unit) -> (unit, Error.t) Result.result
val stop : t -> (unit, Error.t) Result.result
