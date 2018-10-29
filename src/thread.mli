module Request :
sig
  type t
  val make : unit -> t
end

val queue_work :
  ?loop:Loop.t ->
  ?request:Request.t ->
  (unit -> 'return_value) ->
  (('return_value, Error.t) Result.result -> unit) ->
    unit

(* DOC The C function should have signature void (*)(void*); *)
(* TODO Write an example that uses this. *)
val queue_c_work :
  ?loop:Loop.t ->
  ?request:Request.t ->
  ?argument:nativeint ->
  f:nativeint ->
  (Error.t -> unit) ->
    unit

(* DOC This must be called as early as possible, and there are hard limits on
   the number of threads. *)
val set_thread_pool_size : ?if_not_already_set:bool -> int -> unit

(* TODO Synchronization primitives. *)
