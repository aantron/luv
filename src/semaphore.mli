(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Semaphores.

    See {{:http://docs.libuv.org/en/v1.x/threading.html#semaphores}
    {i Semaphores}} in libuv. *)

type t
(** Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_sem_t}
    [uv_sem_t]}. *)

val init : int -> (t, Error.t) result
(** Allocates and initializes a semaphore.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_sem_init}
    [uv_sem_init]}. See
    {{:http://man7.org/linux/man-pages/man3/sem_init.3p.html}
    [sem_init(3p)]}. *)

val destroy : t -> unit
(** Cleans up a semaphore.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_sem_destroy}
    [uv_sem_destroy]}. See
    {{:http://man7.org/linux/man-pages/man3/sem_destroy.3p.html}
    [sem_destroy(3p)]}. *)

val post : t -> unit
(** Increments a semaphore.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_sem_post}
    [uv_sem_post]}. See
    {{:http://man7.org/linux/man-pages/man3/sem_post.3p.html}
    [sem_post(3p)]}. *)

val wait : t -> unit
(** Decrements a semaphore.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_sem_wait}
    [uv_sem_wait]}. See
    {{:http://man7.org/linux/man-pages/man3/sem_wait.3p.html}
    [sem_wait(3p)]}. *)

val trywait : t -> (unit, Error.t) result
(** Tries to decrement a semaphore without blocking.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_sem_trywait}
    [uv_sem_trywait]}. See
    {{:http://man7.org/linux/man-pages/man3/sem_trywait.3p.html}
    [sem_trywait(3p)]}. *)
