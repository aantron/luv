(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Event loops.

    See {{:https://aantron.github.io/luv/basics.html#event-loops} {i Event
    loops}} in the user guide and {{:http://docs.libuv.org/en/v1.x/loop.html}
    [uv_loop_t] — {i Event loop}} in libuv. *)

type t = C.Types.Loop.t Ctypes.ptr
(** Binds {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_loop_t}
    [uv_loop_t]}. *)

(** Binds {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_run_mode}
    [uv_run_mode]}. *)
module Run_mode :
sig
  type t = [
    | `DEFAULT
    | `ONCE
    | `NOWAIT
  ]
end

val run : ?loop:t -> ?mode:Run_mode.t -> unit -> bool
(** Runs an event loop.

    Binds {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_run} [uv_run]}.

    If [?loop] is specified, the given loop will be run. If not, this function
    will run {!Luv.Loop.default}, which is suitable for most cases.

    See {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_run} [uv_run]} for the
    meaning of the constants that can be specified with [?mode]. The default
    value is [`DEFAULT].

    This function typically should not be called by a library based on Luv.
    Rather, it should be called by applications. *)

val stop : t -> unit
(** Stops an event loop.

    Binds {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_stop} [uv_stop]}. *)

val default : unit -> t
(** Returns the default event loop.

    Binds {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_default_loop}
    [uv_default_loop]}. *)

val init : unit -> (t, Error.t) result
(** Allocates and initializes a new event loop.

    Binds {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_loop_init}
    [uv_loop_init]}. *)

val close : t -> (unit, Error.t) result
(** Releases resources associated with an event loop.

    Binds {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_loop_close}
    [uv_loop_close]}. *)

val now : t -> Unsigned.UInt64.t
(** Returns the cached loop timestamp.

    Binds {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_now} [uv_now]}. *)

val update_time : t -> unit
(** Updates the cached loop timestamp.

    Binds {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_update_time}
    [uv_update_time]}. *)

(** Binds {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_loop_configure}
    [uv_loop_option]}. *)
module Option :
sig
  type 'value t
  val block_signal : int t
  val sigprof : int
end

val configure : t -> 'value Option.t -> 'value -> (unit, Error.t) result
(** Sets a loop option.

    Binds {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_loop_configure}
    [uv_loop_configure]}. *)

val alive : t -> bool
(** Indicates whether the loop is monitoring any activity.

    Binds {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_loop_alive}
    [uv_loop_alive]}. *)

val backend_fd : t -> int option
(** Returns the file descriptor used for I/O polling.

    Binds {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_backend_fd}
    [uv_backend_fd]}. *)

val backend_timeout : t -> int option
(** Returns the timeout used with I/O polling.

    Binds {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_backend_timeout}
    [uv_backend_timeout]}. *)

val fork : t -> (unit, Error.t) result
(** Reinitializes libuv after a call to [fork(2)].

    Binds {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_loop_fork}
    [uv_loop_fork]}. *)

(**/**)

(* Internal functions; do not use. *)

val or_default : t option -> t
