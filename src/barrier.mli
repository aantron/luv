(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Barriers.

    See {{:http://docs.libuv.org/en/v1.x/threading.html#barriers}
    {i Barriers}} in libuv. *)

type t
(** Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_barrier_t}
    [uv_barrier_t]}. *)

val init : int -> (t, Error.t) result
(** Allocates and initializes a barrier.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_barrier_init}
    [uv_barrier_init]}. *)

val destroy : t -> unit
(** Cleans up a barrier.

    Binds
    {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_barrier_destroy}
    [uv_barrier_destroy]}. *)

val wait : t -> bool
(** Waits on a barrier.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_barrier_wait}
    [uv_barrier_wait]}. *)