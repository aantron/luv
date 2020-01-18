(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `UDP ] Handle.t

module Membership :
sig
  type t = [
    | `LEAVE_GROUP
    | `JOIN_GROUP
  ]
end

val init :
  ?loop:Loop.t -> ?domain:Misc.Address_family.t -> unit -> (t, Error.t) result
val open_ : t -> Misc.Os_socket.t -> (unit, Error.t) result
val bind :
  ?ipv6only:bool -> ?reuseaddr:bool -> t -> Misc.Sockaddr.t ->
    (unit, Error.t) result
val getsockname : t -> (Misc.Sockaddr.t, Error.t) result
val set_membership :
  t -> group:string -> interface:string -> Membership.t ->
    (unit, Error.t) result
val set_source_membership :
  t -> group:string -> interface:string -> source:string -> Membership.t ->
    (unit, Error.t) result
val set_multicast_loop : t -> bool -> (unit, Error.t) result
val set_multicast_ttl : t -> int -> (unit, Error.t) result
val set_multicast_interface : t -> string -> (unit, Error.t) result
val set_broadcast : t -> bool -> (unit, Error.t) result
val set_ttl : t -> int -> (unit, Error.t) result
(* DOC The write is always full. *)
val send :
  t ->
  Buffer.t list ->
  Misc.Sockaddr.t ->
  ((unit, Error.t) result -> unit) ->
    unit
val try_send : t -> Buffer.t list -> Misc.Sockaddr.t -> (unit, Error.t) result

module Recv_flag :
sig
  type t = [
    | `PARTIAL
  ]
end

val recv_start :
  ?allocate:(int -> Buffer.t) ->
  ?buffer_not_used:(unit -> unit) ->
  t ->
  ((Buffer.t * Misc.Sockaddr.t * Recv_flag.t list, Error.t) result ->
    unit) ->
    unit

val recv_stop : t -> (unit, Error.t) result
val get_send_queue_size : t -> int
val get_send_queue_count : t -> int

module Connected :
sig
  val connect : t -> Misc.Sockaddr.t -> (unit, Error.t) result
  val disconnect : t -> (unit, Error.t) result
  val getpeername : t -> (Misc.Sockaddr.t, Error.t) result
  val send : t -> Buffer.t list -> ((unit, Error.t) result -> unit) -> unit
  val try_send : t -> Buffer.t list -> (unit, Error.t) result
end
