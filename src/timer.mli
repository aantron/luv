(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Timers.

    See {{:http://docs.libuv.org/en/v1.x/timer.html} [uv_timer_t] {i - Timer
    handle}}. *)

type t = [ `Timer ] Handle.t
(** Binds {{:http://docs.libuv.org/en/v1.x/timer.html#c.uv_timer_t}
    [uv_timer_t]}.

    Note that values of this type can be passed to functions in {!Luv.Handle},
    in addition to the functions in this module. In particular, see
    {!Luv.Handle.close}. *)

val init : ?loop:Loop.t -> unit -> (t, Error.t) result
(** Allocates and initializes a timer.

    Binds {{:http://docs.libuv.org/en/v1.x/timer.html#c.uv_timer_init}
    [uv_timer_init]}. *)

val start :
  ?call_update_time:bool -> ?repeat:int -> t -> int -> (unit -> unit) ->
    (unit, Error.t) result
(** Starts a timer.

    Binds {{:http://docs.libuv.org/en/v1.x/timer.html#c.uv_timer_start}
    [uv_timer_start]}. *)

val stop : t -> (unit, Error.t) result
(** Stops a timer.

    Binds {{:http://docs.libuv.org/en/v1.x/timer.html#c.uv_timer_stop}
    [uv_timer_stop]}. *)

val again : t -> (unit, Error.t) result
(** Restarts a timer.

    Binds {{:http://docs.libuv.org/en/v1.x/timer.html#c.uv_timer_again}
    [uv_timer_again]}. *)

val set_repeat : t -> int -> unit
(** Sets the timer repeat interval.

    Binds {{:http://docs.libuv.org/en/v1.x/timer.html#c.uv_timer_set_repeat}
    [uv_timer_set_repeat]}. *)

val get_repeat : t -> int
(** Retrieves the timer repeat interval.

    Binds {{:http://docs.libuv.org/en/v1.x/timer.html#c.uv_timer_get_repeat}
    [uv_timer_get_repeat]}. *)
