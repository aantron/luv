(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `FS_event ] Handle.t

module Event :
sig
  type t = [
    | `RENAME
    | `CHANGE
  ]
end

val init : ?loop:Loop.t -> unit -> (t, Error.t) Result.result
(* DOC Note this function calls the callback multiple times. *)
val start :
  ?watch_entry:bool ->
  ?stat:bool ->
  ?recursive:bool ->
  t ->
  string ->
  ((string * (Event.t list), Error.t) Result.result -> unit) ->
    unit
val stop : t -> (unit, Error.t) Result.result
