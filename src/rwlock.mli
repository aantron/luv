(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Read-write locks.

    See {{:http://docs.libuv.org/en/v1.x/threading.html#read-write-locks}
    {i Read-write locks}} in libuv. *)

type t
(** Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_rwlock_t}
    [uv_rwlock_t]}. *)

val init : unit -> (t, Error.t) result
(** Allocates and initializes a read-write lock.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_rwlock_init}
    [uv_rwlock_init]}. *)

val destroy : t -> unit
(** Cleans up a read-write lock.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_rwlock_destroy}
    [uv_rwlock_destroy]}. *)

val rdlock : t -> unit
(** Takes a read-write lock for reading (shared access).

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_rwlock_rdlock}
    [uv_rwlock_rdlock]}. *)

val tryrdlock : t -> (unit, Error.t) result
(** Tries to take a read-write lock for reading without blocking.

    Binds
    {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_rwlock_tryrdlock}
    [uv_rwlock_tryrdlock]}. *)

val rdunlock : t -> unit
(** Releases a read-write lock after it was taken for reading.

    Binds
    {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_rwlock_rdunlock}
    [uv_rwlock_rdunlock]}. *)

val wrlock : t -> unit
(** Takes a read-write lock for writing (exclusive access).

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_rwlock_wrlock}
    [uv_rwlock_wrlock]}. *)

val trywrlock : t -> (unit, Error.t) result
(** Tries to take a read-write lock for writing without blocking.

    Binds
    {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_rwlock_trywrlock}
    [uv_rwlock_trywrlock]}. *)

val wrunlock : t -> unit
(** Releases a read-write lock after it was taken for writing.

    Binds
    {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_rwlock_wrunlock}
    [uv_rwlock_wrunlock]}. *)
