(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Timers.

    See {{:https://aantron.github.io/luv/basics.html#hello-world} {i Hello,
    world!}} in the user guide and {{:http://docs.libuv.org/en/v1.x/timer.html}
    [uv_timer_t] {i — Timer handle}} in libuv. *)

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
    [uv_timer_start]}.

    As of Luv 0.5.7 and libuv 1.41.0 (March 2021), this function can fail only
    if the timer handle is currently closing, i.e.

    {[
      Luv.Handle.is_closing timer = true
    ]} *)

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

val get_due_in : t -> int
(** Evaluates to the time until the timer expires, or zero if it has already
    expired.

    Binds {{:http://docs.libuv.org/en/v1.x/timer.html#c.uv_timer_get_due_in}
    [uv_timer_get_due_in]}.

    Requires Luv 0.5.6 and libuv 1.40.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has timer_get_due_in)] *)
