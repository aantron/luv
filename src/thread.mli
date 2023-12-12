(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Threads.

    See {{:https://aantron.github.io/luv/threads.html} {i Threads}} in the user
    guide and {{:http://docs.libuv.org/en/v1.x/threading.html} {i Threading and
    synchronization utilities}} in libuv. *)

type t
(** Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_thread_t}
    [uv_thread_t]}. *)

val self : unit -> t
(** Returns the representation of the calling thread.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_thread_self}
    [uv_thread_self]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_self.3p.html}
    [pthread_self(3p)]}. *)

val equal : t -> t -> bool
(** Compares two thread values for equality.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_thread_equal}
    [uv_thread_equal]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_equal.3p.html}
    [pthread_equal(3p)]}. *)

val create : ?stack_size:int -> (unit -> unit) -> (t, Error.t) result
(** Starts a new thread, which will run the given function.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_thread_create}
    [uv_thread_create]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_create.3p.html}
    [pthread_create(3p)]}.

    [?stack_size] does nothing on libuv prior to 1.26.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has thread_stack_size)] *)

val create_c :
  ?stack_size:int ->
  ?argument:nativeint ->
  nativeint ->
    (t, Error.t) result
(** Like {!Luv.Thread.create}, but runs a C function by pointer.

    The C function should have signature [(*)(void*)]. The default value of
    [?argument] is [NULL] (0).

    [?stack_size] does nothing on libuv prior to 1.26.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has thread_stack_size)] *)

val join : t -> (unit, Error.t) result
(** Waits for the given thread to terminate.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_thread_join}
    [uv_thread_join]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_join.3p.html}
    [pthread_join(3p)]}. *)

val setaffinity : t -> bytes -> (bytes, Error.t) result
(** Sets the thread's processor affinity mask.

    Binds
    {{:https://docs.libuv.org/en/v1.x/threading.html#c.uv_thread_setaffinity}
    [uv_thread_setaffinity]}. See
    {{:https://man7.org/linux/man-pages/man3/pthread_setaffinity_np.3.html}
    [pthread_setaffinity_np(3)]} and
    {{:https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setprocessaffinitymask}
    [SetProcessAffinityMask]}.

    See {!Luv.System_info.cpumask_size}.

    Requires Luv 0.5.13 and libuv 1.45.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has setaffinity)] *)

val getaffinity : t -> (bytes, Error.t) result
(** Gets the thread's processor affinity mask.

    Binds
    {{:https://docs.libuv.org/en/v1.x/threading.html#c.uv_thread_getaffinity}
    [uv_thread_getaffinity]}. See
    {{:https://man7.org/linux/man-pages/man3/pthread_getaffinity_np.3.html}
    [pthread_setaffinity_np(3)]} and
    {{:https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getprocessaffinitymask}
    [GetProcessAffinityMask]}.

    See {!Luv.System_info.cpumask_size}.

    Requires Luv 0.5.13 and libuv 1.45.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has getaffinity)] *)
