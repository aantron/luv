module Request :
sig
  type t
  val make : unit -> t
end

val queue_work :
  ?loop:Loop.t ->
  ?request:Request.t ->
  (unit -> 'a) ->
  (('a, Error.t) Result.result -> unit) ->
    unit
(* TODO How should exceptions in the callback be dealt with? *)

(* DOC The C function should have signature void (*)(void*); *)
(* TODO Write an example that uses this. *)
val queue_c_work :
  ?loop:Loop.t ->
  ?request:Request.t ->
  ?argument:nativeint ->
  nativeint ->
  (Error.t -> unit) ->
    unit

(* DOC This must be called as early as possible, and there are hard limits on
   the number of threads. *)
val set_thread_pool_size : ?if_not_already_set:bool -> int -> unit

type 'a t

val self : unit -> unit t
val equal : _ t -> _ t -> bool

(* TODO How should exceptions in the callback be dealt with? *)
val create :
  (unit -> 'a) -> ('a t, Error.t) Result.result

val create_c :
  ?argument:nativeint -> nativeint -> (unit t, Error.t) Result.result

val join :
  'a t -> ('a, Error.t) Result.result
(* DOC Document that concurrent join is undefined? Sequenced joins return ESRCH.
   Basically, each thread can be joined once. *)

module TLS :
sig
  type t

  val create : unit -> (t, Error.t) Result.result
  val delete : t -> unit
  val get : t -> nativeint
  val set : t -> nativeint -> unit
end

module Once :
sig
  type t

  val init : unit -> (t, Error.t) Result.result
  val once : t -> (unit -> unit) -> unit
  val once_c : t -> nativeint -> unit
end

(* DOC destroy can raise sigabrt if the mutex is still locked. This is a
   "feature" of libuv. *)
module Mutex :
sig
  type t

  val init : ?recursive:bool -> unit -> (t, Error.t) Result.result
  val destroy : t -> unit
  val lock : t -> unit
  val trylock : t -> Error.t
  val unlock : t -> unit
end

module Rwlock :
sig
  type t

  val init : unit -> (t, Error.t) Result.result
  val destroy : t -> unit
  val rdlock : t -> unit
  val tryrdlock : t -> Error.t
  val rdunlock : t -> unit
  val wrlock : t -> unit
  val trywrlock : t -> Error.t
  val wrunlock : t -> unit
end

module Semaphore :
sig
  type t

  val init : int -> (t, Error.t) Result.result
  val destroy : t -> unit
  val post : t -> unit
  val wait : t -> unit
  val trywait : t -> Error.t
end

(* DOC Time units for timedwait? nanoseconds, so the type might need to be
   int64, or the timeout should be scaled internally. *)
module Condition :
sig
  type t

  val init : unit -> (t, Error.t) Result.result
  val destroy : t -> unit
  val signal : t -> unit
  val broadcast : t -> unit
  val wait : t -> Mutex.t -> unit
  val timedwait : t -> Mutex.t -> int -> Error.t
end

module Barrier :
sig
  type t

  val init : int -> (t, Error.t) Result.result
  val destroy : t -> unit
  val wait : t -> bool
end
