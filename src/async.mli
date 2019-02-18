(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `Async ] Handle.t

val init : ?loop:Loop.t -> (t -> unit) -> (t, Error.t) Result.result
val send : t -> Error.t
