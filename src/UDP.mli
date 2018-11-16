type t = [ `UDP ] Stream.t

module Bind_flag :
sig
  type t

  val ipv6only : t
  val reuseaddr : t

  val list : t list -> t
  val (lor) : t -> t -> t
end

module Membership :
sig
  type t

  val join_group : t
  val leave_group : t
end

val init :
  ?loop:Loop.t -> ?domain:Misc.Address_family.t -> unit ->
    (t, Error.t) Result.result
val open_ : t -> Misc.Os_socket.t -> Error.t
val bind : ?flags:Bind_flag.t -> t -> Misc.Sockaddr.t -> Error.t
val getsockname : t -> (Misc.Sockaddr.t, Error.t) Result.result
val set_membership :
  t -> group:string -> interface:string -> Membership.t -> Error.t
val set_multicast_loop : t -> bool -> Error.t
val set_multicast_ttl : t -> int -> Error.t
val set_multicast_interface : t -> string -> Error.t
val set_ttl : t -> int -> Error.t
(* DOC The write is always full. *)
val send : t -> Bigstring.t list -> Misc.Sockaddr.t -> (Error.t -> unit) -> unit
val try_send : t -> Bigstring.t list -> Misc.Sockaddr.t -> Error.t

(* DOC The boolean is a flag for whether the read was partial. *)
val recv_start :
  ?allocate:(int -> Bigstring.t) ->
  ?buffer_not_used:(unit -> unit) ->
  t ->
  ((Bigstring.t * Misc.Sockaddr.t * bool, Error.t) Result.result -> unit) ->
    unit

val recv_stop : t -> Error.t
val get_send_queue_size : t -> int
val get_send_queue_count : t -> int
