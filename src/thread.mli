(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Pool :
sig
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

  (* DOC The C function should have signature void (*)(void*); *)
  (* TODO Write an example that uses this. *)
  val queue_c_work :
    ?loop:Loop.t ->
    ?request:Request.t ->
    ?argument:nativeint ->
    nativeint ->
    ((unit, Error.t) result -> unit) ->
      unit

  (* DOC This must be called as early as possible, and there are hard limits on
     the number of threads. *)
  val set_size : ?if_not_already_set:bool -> int -> unit
end

type t

val self : unit -> t
val equal : t -> t -> bool

val create : ?stack_size:int -> (unit -> unit) -> (t, Error.t) result
val create_c :
  ?stack_size:int ->
  ?argument:nativeint ->
  nativeint ->
    (t, Error.t) result

val join : t -> (unit, Error.t) result
(* DOC Document that concurrent join is undefined? Sequenced joins return ESRCH.
   Basically, each thread can be joined once. *)

module TLS :
sig
  type t

  val create : unit -> (t, Error.t) result
  val delete : t -> unit
  val get : t -> nativeint
  val set : t -> nativeint -> unit
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
