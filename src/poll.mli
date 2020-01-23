(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `Poll ] Handle.t

module Event :
sig
  type t = [
    | `READABLE
    | `WRITABLE
    | `DISCONNECT
    | `PRIORITIZED
  ]
end

val init : ?loop:Loop.t -> int -> (t, Error.t) result
val init_socket : ?loop:Loop.t -> Misc.Os_fd.Socket.t -> (t, Error.t) result
val start :
  t -> Event.t list -> ((Event.t list, Error.t) result -> unit) -> unit
val stop : t -> (unit, Error.t) result
