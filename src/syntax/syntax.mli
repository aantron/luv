(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type 'a cps = ('a -> unit) -> unit

val ( let* ) : 'a cps -> ('a -> 'b cps) -> 'b cps
val ( and* ) : 'a cps -> 'b cps -> ('a * 'b) cps

val ( let+ ) : 'a cps -> ('a -> 'b) -> 'b cps
val ( and+ ) : 'a cps -> 'b cps -> ('a * 'b) cps

val ( let- ) : 'a cps -> ('a -> unit) -> unit
val ( and- ) : 'a cps -> 'b cps -> ('a * 'b) cps
