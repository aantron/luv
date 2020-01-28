(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Condition variables.

    See {{:http://docs.libuv.org/en/v1.x/threading.html#conditions}
    {i Conditions}} in libuv. *)

type t
(** Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_cond_t}
    [uv_cond_t]}. *)

val init : unit -> (t, Error.t) result
(** Allocates and initializes a condition variable.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_cond_init}
    [uv_cond_init]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_cond_init.3p.html}
    [pthread_cond_init(3p)]}. *)

val destroy : t -> unit
(** Cleans up a condition variable.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_cond_destroy}
    [uv_cond_destroy]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_cond_destroy.3p.html}
    [pthread_cond_destroy(3p)]}. *)

val signal : t -> unit
(** Signals a condition variable.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_cond_signal}
    [uv_cond_signal]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_cond_signal.3p.html}
    [pthread_cond_signal(3p)]}. *)

val broadcast : t -> unit
(** Signals a condition variable, waking all waiters.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_cond_broadcast}
    [uv_cond_broadcast]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_cond_broadcast.3p.html}
    [pthread_cond_broadcast(3p)]}. *)

val wait : t -> Mutex.t -> unit
(** Waits on a condition variable.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_cond_wait}
    [uv_cond_wait]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_cond_wait.3p.html}
    [pthread_cond_wait(3p)]}. *)

val timedwait : t -> Mutex.t -> int -> (unit, Error.t) result
(** Like {!Luv.Condition.wait}, but with a timeout.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_cond_timedwait}
    [uv_cond_timedwait]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_cond_timedwait.3p.html}
    [pthread_cond_timedwait(3p)]}.

    The timeout is given in nanoseconds. *)
