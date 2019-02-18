(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `FS_event ] Handle.t

module Event :
sig
  type t

  val rename : t
  val change : t

  val test : t -> t -> bool
end

module Flag :
sig
  type t

  val recursive : t
end

val init : ?loop:Loop.t -> unit -> (t, Error.t) Result.result
val start :
  ?flags:Flag.t ->
  t ->
  string ->
  ((string * Event.t, Error.t) Result.result -> unit) ->
    unit
val stop : t -> Error.t
