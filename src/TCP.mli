(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** TCP sockets.

    See {{:http://docs.libuv.org/en/v1.x/tcp.html} [uv_tcp_t] {i - TCP
    handle}}. *)

type t = [ `TCP ] Stream.t
(** Binds {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_tcp_t} [uv_tcp_t]}.

    Note that values of this type can also be used with functions in:

    - {!Luv.Stream}
    - {!Luv.Handle}

    In particular, see {!Luv.Handle.close}, {!Luv.Stream.accept},
    {!Luv.Stream.read_start}, {!Luv.Stream.write}. *)

val init :
  ?loop:Loop.t -> ?domain:Sockaddr.Address_family.t -> unit ->
    (t, Error.t) result
(** Allocates and initializes a TCP stream.

    Binds {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_tcp_init_ex}
    [uv_tcp_init_ex]}.

    The stream is not yet connected or listening. See {!Luv.TCP.bind},
    {!Luv.Stream.listen}, and {!Luv.Stream.connect}. *)

val open_ : t -> Os_fd.Socket.t -> (unit, Error.t) result
(** Wraps an existing socket in a libuv TCP stream.

    Binds {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_tcp_open}
    [uv_tcp_open]}. *)

val nodelay : t -> bool -> (unit, Error.t) result
(** Sets [TCP_NODELAY].

    Binds {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_tcp_nodelay}
    [uv_tcp_nodelay]}. *)

val keepalive : t -> int option -> (unit, Error.t) result
(** Sets the TCP keepalive.

    Binds {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_tcp_keepalive}
    [uv_tcp_keepalive]}. *)

val simultaneous_accepts : t -> bool -> (unit, Error.t) result
(** Sets simultaneous accept.

    Binds
    {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_tcp_simultaneous_accepts}
    [uv_tcp_simultaneous_accepts]}. *)

val bind : ?ipv6only:bool -> t -> Sockaddr.t -> (unit, Error.t) result
(** Assigns an address to the given TCP socket.

    Binds {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_tcp_bind}
    [uv_tcp_bind]}. *)

val getsockname : t -> (Sockaddr.t, Error.t) result
(** Retrieves the address assigned to the given TCP socket.

    Binds {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_tcp_getsockname}
    [uv_tcp_getsockname]}. *)

val getpeername : t -> (Sockaddr.t, Error.t) result
(** Retrieves the address of the given TCP socket's peer.

    Binds {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_tcp_getpeername}
    [uv_tcp_getpeername]}. *)

val connect : t -> Sockaddr.t -> ((unit, Error.t) result -> unit) -> unit
(** Connects to a host.

    Binds {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_tcp_connect}
    [uv_tcp_connect]}. *)

val close_reset : t -> ((unit, Error.t) result -> unit) -> unit
(** Resets the connection.

    Binds {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_tcp_close_reset}
    [uv_tcp_close_reset]}. *)
