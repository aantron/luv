(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Pipes.

    See {{:https://aantron.github.io/luv/processes.html#child-process-i-o} {i
    Child process I/O}} and {{:https://aantron.github.io/luv/processes.html#ipc}
    {i IPC}} in the user guide, and {{:http://docs.libuv.org/en/v1.x/pipe.html}
    [uv_pipe_t] {i — Pipe handle}} in libuv. *)

type t = [ `Pipe ] Stream.t
(** Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_t} [uv_pipe_t]}.

    Note that values of this type can also be used with functions in:

    - {!Luv.Stream}
    - {!Luv.Handle}

    In particular, see {!Luv.Handle.close}, {!Luv.Stream.accept},
    {!Luv.Stream.read_start}, {!Luv.Stream.write}. *)

val init :
  ?loop:Loop.t -> ?for_handle_passing:bool -> unit -> (t, Error.t) result
(** Allocates and initializes a pipe.

    Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_init}
    [uv_pipe_init]}.

    The pipe is not yet connected to anything at this point. See
    {!Luv.Pipe.bind}, {!Luv.Stream.listen}, and {!Luv.Pipe.connect}. *)

val open_ : t -> File.t -> (unit, Error.t) result
(** Wraps an existing file descriptor in a libuv pipe.

    Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_open}
    [uv_pipe_open]}. *)

val pipe :
  ?read_flags:TCP.Flag.t list -> ?write_flags:TCP.Flag.t list -> unit ->
    (File.t * File.t, Error.t) result
(** Creates a pair of connected pipes.

    Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe} [uv_pipe]}. See
    {{:https://www.man7.org/linux/man-pages/man3/pipe.3p.html} [pipe(3p)]}.

    In case of success, in the value [(read_pipe, write_pipe)], data written
    to [write_pipe] can be read from [read_pipe].

    [?read_flags] specifies flags for [read_pipe]. Likewise, [?write_flags]
    specifies flags for [write_pipe]. The only possible flag at the moment is
    [`NONBLOCK], which binds [UV_NONBLOCK_PIPE]. Both arguments are
    set to [[`NONBLOCK]] by default.

    Requires Luv 0.5.7 and libuv 1.41.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has pipe)] *)

val bind : ?no_truncate:bool -> t -> string -> (unit, Error.t) result
(** Assigns a pipe a name or an address.

    Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_bind2}
    [uv_pipe_bind2]}. See {{:http://man7.org/linux/man-pages/man3/bind.3p.html}
    [bind(3p)]}.

    [?no_truncate] binds [UV_PIPE_NO_TRUNCATE], which causes this function to
    return [EINVAL] rather than truncating the path, if the path is too long.

    [?no_truncate] and Linux abstract namespace sockets require Luv 0.5.13 and
    libuv 1.46.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has pipe_bind2)] *)

val connect :
  ?no_truncate:bool -> t -> string -> ((unit, Error.t) result -> unit) -> unit
(** Connects to the pipe at the given name or address.

    Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_connect2}
    [uv_pipe_connect2]}. See
    {{:http://man7.org/linux/man-pages/man3/connect.3p.html} [connect(3p)]}.

    [?no_truncate] binds [UV_PIPE_NO_TRUNCATE], which causes this function to
    return [EINVAL] rather than truncating the path, if the path is too long.

    [?no_truncate] and Linux abstract namespace sockets require Luv 0.5.13 and
    libuv 1.46.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has pipe_connect2)] *)

val getsockname : t -> (string, Error.t) result
(** Retrieves the name or address assigned to the given pipe.

    Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_getsockname}
    [uv_pipe_getsockname]}. See
    {{:http://man7.org/linux/man-pages/man3/getsockname.3p.html}
    [getsockname(3p)]}. *)

val getpeername : t -> (string, Error.t) result
(** Retrieves the name or address of the given pipe's peer.

    Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_getpeername}
    [uv_pipe_getpeername]}. See
    {{:http://man7.org/linux/man-pages/man3/getpeername.3p.html}
    [getpeername(3p)]}. *)

val pending_instances : t -> int -> unit
(** Binds
    {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_pending_instances}
    [uv_pipe_pending_instances]}. *)

val receive_handle :
  t -> [
    | `TCP of (TCP.t -> (unit, Error.t) result)
    | `Pipe of (t -> (unit, Error.t) result)
    | `None
  ]
(** Receives a file descriptor over the given pipe.

    File descriptors are sent using the [~send_handle] argument of
    {!Luv.Stream.write2}.

    On the receiving end, call {!Luv.Stream.read_start}. When that function
    calls its callback, there may be file descriptors in the pipe, in addition
    to the ordinary data provided to the callback.

    To check, call this function {!Luv.Pipe.receive_handle} in a loop until it
    returns [`None]. Each time it returns [`TCP receive] or [`Pipe receive],
    create an appropriate [handle] using either {!Luv.TCP.init} or
    {!Luv.Pipe.init}, and call [receive handle] to receive the file descriptor
    and associate it with [handle]. *)

(** Constants for {!Luv.Pipe.chmod}. *)
module Mode :
sig
  type t = [
    | `READABLE
    | `WRITABLE
  ]
end

val chmod : t -> Mode.t list -> (unit, Error.t) result
(** Sets pipe permissions.

    Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_chmod}
    [uv_pipe_chmod]}.

    Requires libuv 1.16.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has pipe_chmod)] *)
