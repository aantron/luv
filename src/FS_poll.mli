(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `FS_poll ] Handle.t

val init : ?loop:Loop.t -> unit -> (t, Error.t) Result.result
val start :
  ?interval:int ->
  t ->
  string ->
  ((File.Stat.t * File.Stat.t, Error.t) Result.result -> unit) ->
    unit
val stop : t -> (unit, Error.t) Result.result
