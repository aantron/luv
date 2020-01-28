(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Thread pool.

    See {{:https://aantron.github.io/luv/threads.html#libuv-thread-pool} {i
    libuv thread pool}} in the user guide and
    {{:http://docs.libuv.org/en/v1.x/threadpool.html} {i Thread pool work
    scheduling}} in libuv. *)

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
