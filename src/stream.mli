(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Streams.

    See {{:http://docs.libuv.org/en/v1.x/stream.html} [uv_stream_t] {i - Stream
    handle}}.

    Several types of {{!Luv.Handle.t} handle} have a portion of their interface
    in common, which portion is abstracted out into this module {!Luv.Stream}.

    Concreate streams are:

    - {!Luv.Pipe.t}
    - {!Luv.TCP.t}
    - {!Luv.TTY.t} *)

type 'kind t = [ `Stream of 'kind ] Handle.t
(** Binds {{:http://docs.libuv.org/en/v1.x/stream.html#c.uv_stream_t}
    [uv_stream_t]}. *)

val shutdown : _ t -> ((unit, Error.t) result -> unit) -> unit
(** Shuts down the write side of the stream.

    Binds {{:http://docs.libuv.org/en/v1.x/stream.html#c.uv_shutdown}
    [uv_shutdown]}. *)

val listen :
  ?backlog:int -> _ t -> ((unit, Error.t) result -> unit) -> unit
(** Starts listening for incoming connections.

    Binds {{:http://docs.libuv.org/en/v1.x/stream.html#c.uv_listen}
    [uv_listen]}.

    The default value of [?backlog] is [SOMAXCONN]. *)

val accept : server:'kind t -> client:'kind t -> (unit, Error.t) result
(** Accepts an incoming connection.

    Binds {{:http://docs.libuv.org/en/v1.x/stream.html#c.uv_accept}
    [uv_accept]}.

    [~client] should be a freshly-initialized stream of the same kind as
    [~server]. In other words, if [~server] is a {!Luv.TCP.t}, [~client] should
    also be a {!Luv.TCP.t}, and should have been obtained from
    {!Luv.TCP.init}. *)

val read_start :
  ?allocate:(int -> Buffer.t) ->
  _ t ->
  ((Buffer.t, Error.t) result -> unit) ->
    unit
(** Starts calling its callback whenever data is available on the stream.

    Binds {{:http://docs.libuv.org/en/v1.x/stream.html#c.uv_read_start}
    [uv_read_start]}.

    [?allocate] is called before each call to the main callback, to create a
    the buffer into which the data will be read. One particular use of it is to
    always read data into the same buffer. The argument passed to [?allocate] is
    a suggested size. It is acceptable to return a buffer of a smaller size. To
    read into an existing buffer, but not at its beginning, use
    {!Luv.Buffer.sub} to create a view into the buffer. The default [?allocate]
    allocates a fresh buffer of the given size every time it is called.

    To read only once, call {!Luv.Stream.read_stop} immediately, in the main
    callback. *)

val read_stop : _ t -> (unit, Error.t) result
(** Stops reading.

    Binds {{:http://docs.libuv.org/en/v1.x/stream.html#c.uv_read_stop}
    [uv_read_stop]}. *)

val write :
  ?send_handle:[< `TCP | `Pipe ] t ->
  _ t ->
  Buffer.t list ->
  ((unit, Error.t) result -> int -> unit) ->
    unit
(** Writes the given buffer to the stream.

    Binds {{:http://docs.libuv.org/en/v1.x/stream.html#c.uv_write} [uv_write]}.

    To write only part of a buffer, use {!Luv.Buffer.sub} to create a view into
    the buffer, and pass the view to this function {!Luv.Stream.write}.

    The second argument passed to the callback is the number of bytes written.

    [?send_handle] can be used to send file descriptors if the stream is a
    {!Luv.Pipe.t}. See {!Luv.Pipe.receive_handle}. *)

val try_write : _ t -> Buffer.t list -> (int, Error.t) result
(** Like {!Luv.Stream.write}, but only attempts to perform the write operation
    immediately.

    Binds {{:http://docs.libuv.org/en/v1.x/stream.html#c.uv_try_write}
    [uv_try_write]}. *)

val is_readable : _ t -> bool
(** Indicates whether the given stream is readable (has data).

    Binds {{:http://docs.libuv.org/en/v1.x/stream.html#c.uv_is_readable}
    [uv_is_readable]}. *)

val is_writable : _ t -> bool
(** Indicates whether the given stream is writable (has space in buffers).

    Binds {{:http://docs.libuv.org/en/v1.x/stream.html#c.uv_is_writable}
    [uv_is_writable]}. *)

val set_blocking : _ t -> bool -> (unit, Error.t) result
(** Sets the blocking mode of a stream.

    Binds {{:http://docs.libuv.org/en/v1.x/stream.html#c.uv_stream_set_blocking}
    [uv_stream_set_blocking]}. *)

(**/**)

module Connect_request :
sig
  type t = [ `Connect ] Request.t
  val make : unit -> t
  val trampoline :
    (C.Types.Stream.Connect_request.t Ctypes.ptr -> int -> unit)
      Ctypes.static_funptr
end

val allocate : ('kind C.Types.Stream.t) Ctypes.typ -> 'kind t
val coerce : _ t -> [ `Base ] t
