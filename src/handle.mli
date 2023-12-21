(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Handles.

    See {{:../../../basics.html#handles} {i Handles}} in the user guide and
    {{:http://docs.libuv.org/en/v1.x/handle.html} [uv_handle_t] — {i Base
    handle}} in libuv.

    In libuv, [uv_handle_t] is a sort of “abstract” base type that supports
    functions common to all handles. All concrete handles are of more specific
    types, such as [uv_udp_t].

    Correspondingly, this module, {!Luv.Handle}, offers functions that work on
    all handles, [_ Luv.Handle.t]. Other modules define specific handle types,
    such as {!Luv.UDP.t}, which is defined as [[`UDP] Luv.Handle.t].

    The full list of concrete handle types:

    - {!Luv.Async.t}
    - {!Luv.Check.t}
    - {!Luv.FS_event.t}
    - {!Luv.FS_poll.t}
    - {!Luv.Idle.t}
    - {!Luv.Pipe.t}
    - {!Luv.Poll.t}
    - {!Luv.Prepare.t}
    - {!Luv.Process.t}
    - {!Luv.Signal.t}
    - {!Luv.TCP.t}
    - {!Luv.Timer.t}
    - {!Luv.TTY.t}
    - {!Luv.UDP.t} *)



(** {1 Basics} *)

type 'kind t = 'kind C.Types.Handle.t Ctypes.ptr
(** Binds {{:http://docs.libuv.org/en/v1.x/handle.html#c.uv_handle_t}
    [uv_handle_t]}.

    There is no way to directly create values of this type through this module,
    {!Luv.Handle}. See other modules, which bind specific handle types, such as
    {!Luv.UDP}. *)

val close : _ t -> (unit -> unit) -> unit
(** Closes the given handle.

    Binds {{:http://docs.libuv.org/en/v1.x/handle.html#c.uv_close}
    [uv_close]}. *)

val is_active : _ t -> bool
(** Binds {{:http://docs.libuv.org/en/v1.x/handle.html#c.uv_is_active}
    [uv_is_active]}. *)

val is_closing : _ t -> bool
(** Binds {{:http://docs.libuv.org/en/v1.x/handle.html#c.uv_is_closing}
    [uv_is_closing]}. *)

val ref : _ t -> unit
(** Binds {{:http://docs.libuv.org/en/v1.x/handle.html#c.uv_ref} [uv_ref]}. *)

val unref : _ t -> unit
(** Binds {{:http://docs.libuv.org/en/v1.x/handle.html#c.uv_unref}
    [uv_unref]}. *)

val has_ref : _ t -> bool
(** Binds {{:http://docs.libuv.org/en/v1.x/handle.html#c.uv_has_ref}
    [uv_has_ref]}. *)

val get_loop : _ t -> Loop.t
(** Binds {{:http://docs.libuv.org/en/v1.x/handle.html#c.uv_handle_get_loop}
    [uv_get_loop]}. *)



(** {1 I/O properties} *)

val send_buffer_size :
  [< `Stream of [< `TCP | `Pipe ] | `UDP ] t -> (int, Error.t) result
(** Gets the size of the OS send buffer for a socket.

    Calls {{:http://docs.libuv.org/en/v1.x/handle.html#c.uv_send_buffer_size}
    [uv_send_buffer_size]} with [*value] set to zero. *)

val recv_buffer_size :
  [< `Stream of [< `TCP | `Pipe ] | `UDP ] t -> (int, Error.t) result
(** Gets the size of the OS receive buffer for a socket.

    Calls {{:http://docs.libuv.org/en/v1.x/handle.html#c.uv_recv_buffer_size}
    [uv_recv_buffer_size]} with [*value] set to zero. *)

val set_send_buffer_size :
  [< `Stream of [< `TCP | `Pipe ] | `UDP ] t -> int ->
    (unit, Error.t) result
(** Sets the size of the OS send buffer for a socket.

    Calls {{:http://docs.libuv.org/en/v1.x/handle.html#c.uv_send_buffer_size}
    [uv_send_buffer_size]} with [*value] set to the given value. *)

val set_recv_buffer_size :
  [< `Stream of [< `TCP | `Pipe ] | `UDP ] t -> int ->
    (unit, Error.t) result
(** Sets the size of the OS receive buffer for a socket.

    Calls {{:http://docs.libuv.org/en/v1.x/handle.html#c.uv_recv_buffer_size}
    [uv_recv_buffer_size]} with [*value] set to the given value. *)

val fileno :
  [< `Stream of [< `TCP | `Pipe | `TTY ] | `UDP | `Poll ] t ->
    (Os_fd.Fd.t, Error.t) result
(** Retrieves the file descriptor associated with the handle.

    Binds {{:http://docs.libuv.org/en/v1.x/handle.html#c.uv_fileno}
    [uv_fileno]}. *)



(**/**)

(* Internal functions; do not use. *)

val allocate :
  ?reference_count:int -> 'kind C.Types.Handle.t Ctypes.typ -> 'kind t
val release : _ t -> unit
val set_reference : ?index:int -> _ t -> _ -> unit
val coerce :
  _ C.Types.Handle.t Ctypes.ptr -> [ `Base ] C.Types.Handle.t Ctypes.ptr
