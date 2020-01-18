(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(* TODO Good enough example, as it will be linked from loop.mli. *)
type t = [ `Timer ] Handle.t

val init : ?loop:Loop.t -> unit -> (t, Error.t) result
val start :
  ?call_update_time:bool -> ?repeat:int -> t -> int -> (unit -> unit) ->
    (unit, Error.t) result
val stop : t -> (unit, Error.t) result
val again : t -> (unit, Error.t) result
val set_repeat : t -> int -> unit
val get_repeat : t -> int
