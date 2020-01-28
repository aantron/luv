(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Filesystem polling.

    See {{:http://docs.libuv.org/en/v1.x/fs_poll.html} [uv_fs_poll_t] {i — FS
    Poll handle}} in libuv. *)

type t = [ `FS_poll ] Handle.t
(** Binds {{:http://docs.libuv.org/en/v1.x/fs_poll.html#c.uv_fs_poll_t}
    [uv_fs_poll_t]}.

    Note that values of this type can be passed to functions in {!Luv.Handle},
    in addition to the functions in this module. In particular, see
    {!Luv.Handle.close}. *)

val init : ?loop:Loop.t -> unit -> (t, Error.t) result
(** Allocates and initializes an FS polling handle.

    Binds {{:http://docs.libuv.org/en/v1.x/fs_poll.html#c.uv_fs_poll_init}
    [uv_fs_poll_init]}.

    The handle should be cleaned up with {!Luv.Handle.close} when no longer
    needed. *)

val start :
  ?interval:int ->
  t ->
  string ->
  ((File.Stat.t * File.Stat.t, Error.t) result -> unit) ->
    unit
(** Starts the handle and polls the given path for changes.

    Binds {{:http://docs.libuv.org/en/v1.x/fs_poll.html#c.uv_fs_poll_start}
    [uv_fs_poll_start]}.

    The default value of [?interval] is 2000 (milliseconds).

    See {{:http://docs.libuv.org/en/v1.x/fs_poll.html#c.uv_fs_poll_cb}
    [uv_fs_poll_cb]} for a description of the values passed to the callback. *)

val stop : t -> (unit, Error.t) result
(** Stops the handle.

    Binds {{:http://docs.libuv.org/en/v1.x/fs_poll.html#c.uv_fs_poll_stop}
    [uv_fs_poll_stop]}. *)
