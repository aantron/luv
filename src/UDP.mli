(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** UDP sockets.

    See {{:http://docs.libuv.org/en/v1.x/udp.html} [uv_udp_t] {i — UDP
    handle}}. *)

type t = [ `UDP ] Handle.t
(** Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_t} [uv_udp_t]}.

    Note that values of this type can be passed to functions in {!Luv.Handle},
    in addition to the functions in this module. In particular, see
    {!Luv.Handle.close}. *)

val init :
  ?loop:Loop.t -> ?domain:Sockaddr.Address_family.t -> unit ->
    (t, Error.t) result
(** Allocates and initializes a UDP socket.

    Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_init_ex}
    [uv_udp_init_ex]}. *)

val open_ : t -> Os_fd.Socket.t -> (unit, Error.t) result
(** Wraps an existing socket in a libuv UDP handle.

    Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_open}
    [uv_udp_open]}. *)

val bind :
  ?ipv6only:bool -> ?reuseaddr:bool -> t -> Sockaddr.t ->
    (unit, Error.t) result
(** Assigns an address to the given UDP handle.

    Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_bind}
    [uv_udp_bind]}. *)

val getsockname : t -> (Sockaddr.t, Error.t) result
(** Retrieves the address assigned to the given UDP handle.

    Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_getsockname}
    [uv_udp_getsockname]}. *)

(** Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_membership}
    [uv_membership]}. *)
module Membership :
sig
  type t = [
    | `LEAVE_GROUP
    | `JOIN_GROUP
  ]
end

val set_membership :
  t -> group:string -> interface:string -> Membership.t ->
    (unit, Error.t) result
(** Sets multicast group membership.

    Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_set_membership}
    [uv_udp_set_membership]}. *)

val set_source_membership :
  t -> group:string -> interface:string -> source:string -> Membership.t ->
    (unit, Error.t) result
(** Sets source-specific multicast group membership.

    Binds
    {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_set_source_membership}
    [uv_udp_set_source_membership]}. *)

val set_multicast_loop : t -> bool -> (unit, Error.t) result
(** Sets multicast loopback.

    Binds
    {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_set_multicast_loop}
    [uv_udp_set_multicast_loop]}. *)

val set_multicast_ttl : t -> int -> (unit, Error.t) result
(** Sets the multicast TTL.

    Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_set_multicast_ttl}
    [uv_udp_set_multicast_ttl]}. *)

val set_multicast_interface : t -> string -> (unit, Error.t) result
(** Sets the interface to be used for multicast.

    Binds
    {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_set_multicast_interface}
    [uv_udp_set_multicast_interface]}. *)

val set_broadcast : t -> bool -> (unit, Error.t) result
(** Sets broadcast.

    Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_set_broadcast}
    [uv_udp_set_broadcast]}. *)

val set_ttl : t -> int -> (unit, Error.t) result
(** Sets the TTL.

    Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_set_ttl}
    [uv_udp_set_ttl]}. *)

val send :
  t ->
  Buffer.t list ->
  Sockaddr.t ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Sends a datagram.

    Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_send}
    [uv_udp_send]}.

    For connected UDP sockets, see {!Luv.UDP.Connected.send}. *)

val try_send : t -> Buffer.t list -> Sockaddr.t -> (unit, Error.t) result
(** Like {!Luv.UDP.send}, but only attempts to send the datagram immediately.

    Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_try_send}
    [uv_udp_try_send]}.

    For connected UDP sockets, see {!Luv.UDP.Connected.try_send}. *)

(** Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_flags}
    [uv_udp_flags]}. *)
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
  ((Buffer.t * Sockaddr.t * Recv_flag.t list, Error.t) result -> unit) ->
    unit
(** Starts calling its callback whenever a datagram is received on the UDP
    socket.

    Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_recv_start}
    [uv_udp_recv_start]}.

    The behavior is similar to {!Luv.Stream.read_start}. See that function for
    the meaning of the [?allocate] callback. *)

val recv_stop : t -> (unit, Error.t) result
(** Stops the callback provided to {!Luv.UDP.recv_start}.

    Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_recv_stop}
    [uv_udp_recv_stop]}. *)

val get_send_queue_size : t -> int
(** Binds
    {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_get_send_queue_size}
    [uv_udp_get_send_queue_size]}. *)

val get_send_queue_count : t -> int
(** Binds
    {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_get_send_queue_count}
    [uv_udp_get_send_queue_count]}. *)

(** Connected UDP sockets. *)
module Connected :
sig
  val connect : t -> Sockaddr.t -> (unit, Error.t) result
  (** Assigns a peer address to the given socket.

      Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_connect}
      [uv_udp_connect]}. *)

  val disconnect : t -> (unit, Error.t) result
  (** Removes the peer address assigned to the given socket.

      Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_connect}
      [uv_udp_connect]} with [NULL] argument. *)

  val getpeername : t -> (Sockaddr.t, Error.t) result
  (** Retrieves the peer address assigned to the given socket.

      Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_getpeername}
      [uv_udp_getpeername]}. *)

  val send : t -> Buffer.t list -> ((unit, Error.t) result -> unit) -> unit
  (** Like {!Luv.UDP.send}, but the remote address used is the peer address
      assigned to the socket.

      Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_send}
      [uv_udp_send]}. *)

  val try_send : t -> Buffer.t list -> (unit, Error.t) result
  (** Like {!Luv.UDP.try_send}, but the remote address used is the peer address
      assigned to the socket.

      Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_try_send}
      [uv_udp_try_send]}. *)
end
