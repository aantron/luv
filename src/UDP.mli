(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** UDP sockets.

    See {{:https://aantron.github.io/luv/networking.html#udp} {i UDP}} in the
    user guide and {{:http://docs.libuv.org/en/v1.x/udp.html} [uv_udp_t] {i —
    UDP handle}} in libuv. *)

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
    [uv_udp_bind]}. See {{:http://man7.org/linux/man-pages/man3/bind.3p.html}
    [bind(3p)]}. *)

val getsockname : t -> (Sockaddr.t, Error.t) result
(** Retrieves the address assigned to the given UDP handle.

    Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_getsockname}
    [uv_udp_getsockname]}. See
    {{:http://man7.org/linux/man-pages/man3/getsockname.3p.html}
    [getsockname(3p)]}. *)

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
    [uv_udp_send]}. See {{:http://man7.org/linux/man-pages/man3/send.3p.html}
    [send(3p)]}.

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
  t ->
  ((Buffer.t * Sockaddr.t option * Recv_flag.t list, Error.t) result -> unit) ->
    unit
(** Calls its callback whenever a datagram is received on the UDP socket.

    Binds {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_recv_start}
    [uv_udp_recv_start]}. See
    {{:http://docs.libuv.org/en/v1.x/udp.html#c.uv_udp_recv_cb}
    [uv_udp_recv_cb]} and {{:http://man7.org/linux/man-pages/man3/recv.3p.html}
    [recv(3p)]}.

    The behavior is similar to {!Luv.Stream.read_start}. See that function for
    the meaning of the [?allocate] callback.

    The main callback takes a [Sockaddr.t option]. This is usually [Some
    sender_address], carrying the address of the peer. [None] usually indicates
    [EAGAIN] in libuv; libuv still calls the callback, in order to give the C
    user a chance to deallocate the data buffer. Since this is not usually an
    issue in OCaml, it is usually safe to simply ignore calls to the callback
    with sender address [None].

    The buffer can be empty ([Luv.Buffer.size buffer = 0]). This indicates an
    empty datagram.

    Since UDP is connectionless, there is no EOF, and no means to indicate it.

    The [Recv_flag.t list] callback argument can contain [`PARTIAL], which
    indicates that the buffer allocated was too small for the datagram, a prefix
    of the data was received, and the rest of the datagram was dropped.

    In summary, the important possible combinations of callback arguments are:

    - [Error _]: “true” error that should be handled, reported, etc.
    - [Ok (_, None, _)]: [EAGAIN] inside libuv. Should typically be ignored.
    - [Ok (buffer, Some peer, flags)]: datagram received. In this case, there
      are additional possibilities:
      {ul
      {- [Luv.Buffer.size buffer = 0]: the datagram is empty, because an empty
         datagram was sent.}
      {- [List.mem `PARTIAL flags = true]: the read was partial, because the
         buffer was too small for the datagram.}} *)

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
