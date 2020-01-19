(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** File system events.

    See {{:http://docs.libuv.org/en/v1.x/fs_event.html} [uv_fs_event_t] {i - FS
    Event handle}}. *)

type t = [ `FS_event ] Handle.t
(** Binds {{:http://docs.libuv.org/en/v1.x/fs_event.html#c.uv_fs_event_t}
    [uv_fs_event_t]}.

    Note that values of this type can be passed to functions in {!Luv.Handle},
    in addition to the functions in this module. In particular, see
    {!Luv.Handle.close}. *)

(** Binds {{:http://docs.libuv.org/en/v1.x/fs_event.html#c.uv_fs_event}
    [uv_fs_event]}. *)
module Event :
sig
  type t = [
    | `RENAME
    | `CHANGE
  ]
end

val init : ?loop:Loop.t -> unit -> (t, Error.t) result
(** Allocates and initializes an FS event handle.

    Binds {{:http://docs.libuv.org/en/v1.x/fs_event.html#c.uv_fs_event_init}
    [uv_fs_event_init]}.

    The handle should be cleaned up with {!Luv.Handle.close} when no longer
    needed. *)

val start :
  ?watch_entry:bool ->
  ?stat:bool ->
  ?recursive:bool ->
  t ->
  string ->
  ((string * (Event.t list), Error.t) result -> unit) ->
    unit
(** Starts the handle and watches the given path for changes.

    Binds {{:http://docs.libuv.org/en/v1.x/fs_event.html#c.uv_fs_event_start}
    [uv_fs_event_start]}.

    [uv_fs_event_start] takes a [flags] argument of type
    {{:http://docs.libuv.org/en/v1.x/fs_event.html#c.uv_fs_event_flags}
    [uv_fs_event_flags]}. {!Luv.FS_event.start} instead takes several optional
    arguments, each named after one of the flags.

    See {{:http://docs.libuv.org/en/v1.x/fs_event.html#c.uv_fs_event_cb}
    [uv_fs_event_cb]} for a description of the values passed to the callback. *)

val stop : t -> (unit, Error.t) result
(** Stops the handle.

    Binds {{:http://docs.libuv.org/en/v1.x/fs_event.html#c.uv_fs_event_stop}
    [uv_fs_event_stop]}. *)
