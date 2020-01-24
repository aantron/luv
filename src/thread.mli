(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Threads.

    See {{:http://docs.libuv.org/en/v1.x/threading.html} {i Threading and
    synchronization utilities}}. *)

type t
(** Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_thread_t}
    [uv_thread_t]}. *)

val self : unit -> t
(** Returns the representation of the calling thread.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_thread_self}
    [uv_thread_self]}. *)

val equal : t -> t -> bool
(** Compares two thread values for equality.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_thread_equal}
    [uv_thread_equal]}. *)

val create : ?stack_size:int -> (unit -> unit) -> (t, Error.t) result
(** Starts a new thread, which will run the given function.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_thread_create}
    [uv_thread_create]}. *)

val create_c :
  ?stack_size:int ->
  ?argument:nativeint ->
  nativeint ->
    (t, Error.t) result
(** Like {!Luv.Thread.create}, but runs a C function by pointer.

    The C function should have signature [(*)(void*)]. The default value of
    [?argument] is [NULL] (0). *)

val join : t -> (unit, Error.t) result
(** Waits for the given thread to terminate.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_thread_join}
    [uv_thread_join]}. *)
