(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Condition variables.

    See {{:http://docs.libuv.org/en/v1.x/threading.html#conditions}
    {i Conditions}}. *)

type t
(** Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_cond_t}
    [uv_cond_t]}. *)

val init : unit -> (t, Error.t) result
(** Allocates and initializes a condition variable.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_cond_init}
    [uv_cond_init]}. *)

val destroy : t -> unit
(** Cleans up a condition variable.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_cond_destroy}
    [uv_cond_destroy]}. *)

val signal : t -> unit
(** Signals a condition variable.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_cond_signal}
    [uv_cond_signal]}. *)

val broadcast : t -> unit
(** Signals a condition variable, waking all waiters.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_cond_broadcast}
    [uv_cond_broadcast]}. *)

val wait : t -> Mutex.t -> unit
(** Waits on a condition variable.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_cond_wait}
    [uv_cond_wait]}. *)

val timedwait : t -> Mutex.t -> int -> (unit, Error.t) result
(** Like {!Luv.Condition.wait}, but with a timeout.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_cond_timedwait}
    [uv_cond_timedwait]}.

    The timeout is given in nanoseconds. *)
