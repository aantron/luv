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
    type t = [ `Thread_pool ] Request.t
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



(** Once-only initialization.

    See
    {{:http://docs.libuv.org/en/v1.x/threading.html#once-only-initialization}
    {i Once-only initialization}}. *)
module Once :
sig
  type t
  (** Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_once_t}
      [uv_once_t]}. *)

  val init : unit -> (t, Error.t) result
  (** Allocates and initializes a once-only barrier.

      Binds
      {{:http://docs.libuv.org/en/v1.x/threading.html#once-only-initialization}
      [UV_ONCE_INIT]}. *)

  val once : t -> (unit -> unit) -> unit
  (** Guards the given callback to be called only once.

      Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_once}
      [uv_once]}. *)

  val once_c : t -> nativeint -> unit
  (** Like {!Luv.Once.once}, but takes a pointer to a C function. *)
end



(** Mutexes.

    See {{:http://docs.libuv.org/en/v1.x/threading.html#mutex-locks} {i Mutex
    locks}}. *)
module Mutex :
sig
  type t
  (** Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_mutex_t}
      [uv_mutex_t]}. *)

  val init : ?recursive:bool -> unit -> (t, Error.t) result
  (** Allocates and initializes a mutex.

      Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_mutex_init}
      [uv_mutex_init]}.

      If [?recursive] is set to [true], calls
      {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_mutex_init_recursive}
      [uv_mutex_init_recursive]} instead. *)

  val destroy : t -> unit
  (** Cleans up a mutex.

      Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_mutex_destroy}
      [uv_mutex_destroy]}. *)

  val lock : t -> unit
  (** Takes a mutex.

      Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_mutex_lock}
      [uv_mutex_lock]}.

      The calling thread is blocked until it obtains the mutex. *)

  val trylock : t -> (unit, Error.t) result
  (** Tries to take the mutex without blocking.

      Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_mutex_trylock}
      [uv_mutex_trylock]}. *)

  val unlock : t -> unit
  (** Releases the mutex.

      Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_mutex_unlock}
      [uv_mutex_unlock]}. *)
end



(** Read-write locks.

    See {{:http://docs.libuv.org/en/v1.x/threading.html#read-write-locks}
    {i Read-write locks}}. *)
module Rwlock :
sig
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
end



(** Semaphores.

    See {{:http://docs.libuv.org/en/v1.x/threading.html#semaphores}
    {i Semaphores}}. *)
module Semaphore :
sig
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
end



(** Condition variables.

    See {{:http://docs.libuv.org/en/v1.x/threading.html#conditions}
    {i Conditions}}. *)
module Condition :
sig
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
end



(** Barriers.

    See {{:http://docs.libuv.org/en/v1.x/threading.html#barriers}
    {i Barriers}}. *)
module Barrier :
sig
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
end
