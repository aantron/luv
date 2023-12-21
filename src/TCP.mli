(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** TCP sockets.

    See {{:../../../networking.html#tcp} {i TCP}} in the user guide and
    {{:http://docs.libuv.org/en/v1.x/tcp.html} [uv_tcp_t] {i — TCP handle}} in
    libuv. *)

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
    {!Luv.Stream.listen}, and {!Luv.TCP.connect}.

    On libuv prior to 1.7.0, using [?domain] causes this function to return
    [Error `ENOSYS] ("Function not implemented").

    {{!Luv.Require} Feature check}: [Luv.Require.(has tcp_init_ex)] *)

val open_ : t -> Os_fd.Socket.t -> (unit, Error.t) result
(** Wraps an existing socket in a libuv TCP stream.

    Binds {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_tcp_open}
    [uv_tcp_open]}. *)

(** Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe}
    [UV_NONBLOCK_PIPE]}. *)
module Flag :
sig
  type t = [
    | `NONBLOCK
  ]
end

val socketpair :
    ?fst_flags:Flag.t list ->
    ?snd_flags:Flag.t list ->
    Sockaddr.Socket_type.t ->
    int ->
      (Os_fd.Socket.t * Os_fd.Socket.t, Error.t) result
(** Creates a pair of connected sockets.

    Binds {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_socketpair}
    [uv_socketpair]}. See
    {{:https://www.man7.org/linux/man-pages/man3/socketpair.3p.html}
    [socketpair(3p)]}.

    See {!Luv.Pipe.pipe} for an explanation of the optional arguments.

    The integer argument is the protocol number.

    Requires Luv 0.5.7 and libuv 1.41.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has socketpair)] *)

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
    [uv_tcp_bind]}. See {{:http://man7.org/linux/man-pages/man3/bind.3p.html}
    [bind(3p)]}. *)

val getsockname : t -> (Sockaddr.t, Error.t) result
(** Retrieves the address assigned to the given TCP socket.

    Binds {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_tcp_getsockname}
    [uv_tcp_getsockname]}. See
    {{:http://man7.org/linux/man-pages/man3/getsockname.3p.html}
    [getsockname(3p)]}. *)

val getpeername : t -> (Sockaddr.t, Error.t) result
(** Retrieves the address of the given TCP socket's peer.

    Binds {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_tcp_getpeername}
    [uv_tcp_getpeername]}. See
    {{:http://man7.org/linux/man-pages/man3/getpeername.3p.html}
    [getpeername(3p)]}. *)

val connect : t -> Sockaddr.t -> ((unit, Error.t) result -> unit) -> unit
(** Connects to a host.

    Binds {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_tcp_connect}
    [uv_tcp_connect]}. See
    {{:http://man7.org/linux/man-pages/man3/connect.3p.html} [connect(3p)]}. *)

val close_reset : t -> ((unit, Error.t) result -> unit) -> unit
(** Resets the connection.

    Binds {{:http://docs.libuv.org/en/v1.x/tcp.html#c.uv_tcp_close_reset}
    [uv_tcp_close_reset]}. *)
