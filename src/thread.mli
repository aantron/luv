(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Threads.

    See {{:http://docs.libuv.org/en/v1.x/threading.html} {i Threading and
    synchronization utilities}}. *)



(** Thread pool.

    See {{:http://docs.libuv.org/en/v1.x/threadpool.html} {i Thread pool work
    scheduling}}. *)
module Pool :
sig
  (** Optional request objects for canceling thread pool requests. Binds
      {{:http://docs.libuv.org/en/v1.x/threadpool.html#c.uv_work_t}
      [uv_work_t]}. *)
  module Request :
  sig
    type t = [ `Work ] Request.t
    val make : unit -> t
  end

  val queue_work :
    ?loop:Loop.t ->
    ?request:Request.t ->
    (unit -> unit) ->
    ((unit, Error.t) result -> unit) ->
      unit
  (** Schedules a function to be called by a thread in the thread pool.

      Binds {{:http://docs.libuv.org/en/v1.x/threadpool.html#c.uv_queue_work}
      [uv_queue_work]}. *)

  val queue_c_work :
    ?loop:Loop.t ->
    ?request:Request.t ->
    ?argument:nativeint ->
    nativeint ->
    ((unit, Error.t) result -> unit) ->
      unit
  (** Schedules a C function to be called by a thread in the thread pool.

      Alternative binding to
      {{:http://docs.libuv.org/en/v1.x/threadpool.html#c.uv_queue_work}
      [uv_queue_work]}.

      The C function is specified by its address. It should have signature
      [(*)(void*)]. The default value is [?argument] is [NULL] (0). *)

  val set_size : ?if_not_already_set:bool -> int -> unit
  (** Sets
      {{:http://docs.libuv.org/en/v1.x/threadpool.html#thread-pool-work-scheduling}
      [UV_THREADPOOL_SIZE]}.

      This function should be called as soon during process startup as
      possible. *)
end



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



(** Thread-local storage.

    See {{:http://docs.libuv.org/en/v1.x/threading.html#thread-local-storage}
    {i Thread-local storage}}. *)
module TLS :
sig
  type t
  (** Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_key_t}
      [uv_key_t]}. *)

  val create : unit -> (t, Error.t) result
  (** Creates a TLS key.

      Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_key_create}
      [uv_key_create]}. *)

  val delete : t -> unit
  (** Deletes a TLS key.

      Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_key_delete}
      [uv_key_delete]}. *)

  val get : t -> nativeint
  (** Retrieves the value at a TLS key.

      Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_key_get}
      [uv_key_get]}. *)

  val set : t -> nativeint -> unit
  (** Sets the value at a TLS key.

      Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_key_set}
      [uv_key_set]}. *)
end



module Once :
sig
  type t

  val init : unit -> (t, Error.t) result
  val once : t -> (unit -> unit) -> unit
  val once_c : t -> nativeint -> unit
end



(* DOC destroy can raise sigabrt if the mutex is still locked. This is a
   "feature" of libuv. *)
module Mutex :
sig
  type t

  val init : ?recursive:bool -> unit -> (t, Error.t) result
  val destroy : t -> unit
  val lock : t -> unit
  val trylock : t -> (unit, Error.t) result
  val unlock : t -> unit
end



module Rwlock :
sig
  type t

  val init : unit -> (t, Error.t) result
  val destroy : t -> unit
  val rdlock : t -> unit
  val tryrdlock : t -> (unit, Error.t) result
  val rdunlock : t -> unit
  val wrlock : t -> unit
  val trywrlock : t -> (unit, Error.t) result
  val wrunlock : t -> unit
end



module Semaphore :
sig
  type t

  val init : int -> (t, Error.t) result
  val destroy : t -> unit
  val post : t -> unit
  val wait : t -> unit
  val trywait : t -> (unit, Error.t) result
end



(* DOC Time units for timedwait? nanoseconds, so the type might need to be
   int64, or the timeout should be scaled internally. *)
module Condition :
sig
  type t

  val init : unit -> (t, Error.t) result
  val destroy : t -> unit
  val signal : t -> unit
  val broadcast : t -> unit
  val wait : t -> Mutex.t -> unit
  val timedwait : t -> Mutex.t -> int -> (unit, Error.t) result
end



module Barrier :
sig
  type t

  val init : int -> (t, Error.t) result
  val destroy : t -> unit
  val wait : t -> bool
end
