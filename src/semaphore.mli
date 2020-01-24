(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Semaphores.

    See {{:http://docs.libuv.org/en/v1.x/threading.html#semaphores}
    {i Semaphores}}. *)

type t
(** Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_sem_t}
    [uv_sem_t]}. *)

val init : int -> (t, Error.t) result
(** Allocates and initializes a semaphore.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_sem_init}
    [uv_sem_init]}. *)

val destroy : t -> unit
(** Cleans up a semaphore.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_sem_destroy}
    [uv_sem_destroy]}. *)

val post : t -> unit
(** Increments a semaphore.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_sem_post}
    [uv_sem_post]}. *)

val wait : t -> unit
(** Decrements a semaphore.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_sem_wait}
    [uv_sem_wait]}. *)

val trywait : t -> (unit, Error.t) result
(** Tries to decrement a semaphore without blocking.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_sem_trywait}
    [uv_sem_trywait]}. *)
