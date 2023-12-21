(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Mutexes.

    See {{:../../../threads.html#synchronization-primitives} {i Synchronization
    primitives}} in the user guide and
    {{:http://docs.libuv.org/en/v1.x/threading.html#mutex-locks} {i Mutex
    locks}} in libuv. *)

type t = C.Types.Mutex.t Ctypes.ptr
(** Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_mutex_t}
    [uv_mutex_t]}. *)

val init : ?recursive:bool -> unit -> (t, Error.t) result
(** Allocates and initializes a mutex.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_mutex_init}
    [uv_mutex_init]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_mutex_init.3p.html}
    [pthread_mutex_init(3p)]}.

    If [?recursive] is set to [true], calls
    {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_mutex_init_recursive}
    [uv_mutex_init_recursive]} instead.

    [?recursive] requires libuv 1.15.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has mutex_init_recursive)] *)

val destroy : t -> unit
(** Cleans up a mutex.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_mutex_destroy}
    [uv_mutex_destroy]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_mutex_destroy.3p.html}
    [pthread_mutex_destroy(3p)]}. *)

val lock : t -> unit
(** Takes a mutex.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_mutex_lock}
    [uv_mutex_lock]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_mutex_lock.3p.html}
    [pthread_mutex_lock(3p)]}.

    The calling thread is blocked until it obtains the mutex. *)

val trylock : t -> (unit, Error.t) result
(** Tries to take the mutex without blocking.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_mutex_trylock}
    [uv_mutex_trylock]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_mutex_trylock.3p.html}
    [pthread_mutex_trylock(3p)]}. *)

val unlock : t -> unit
(** Releases the mutex.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_mutex_unlock}
    [uv_mutex_unlock]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_mutex_unlock.3p.html}
    [pthread_mutex_unlock(3p)]}. *)
