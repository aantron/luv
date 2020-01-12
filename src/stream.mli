(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type 'kind t = [ `Stream of 'kind ] Handle.t

val shutdown : _ t -> ((unit, Error.t) Result.result -> unit) -> unit
(* DOC If backlog not provided, SOMAXCONN specified *)
val listen :
  ?backlog:int -> _ t -> ((unit, Error.t) Result.result -> unit) -> unit
val accept : server:'kind t -> client:'kind t -> (unit, Error.t) Result.result

(* DOC Document how to use allocate and read_stop together for in-place
   reading into a single buffer. *)
val read_start :
  ?allocate:(int -> Bigstring.t) ->
  _ t ->
  ((Bigstring.t, Error.t) Result.result -> unit) ->
    unit
val read_stop : _ t -> (unit, Error.t) Result.result

(* DOC how to use Array1.sub to create views into the arrays. *)
(* DOC What is the int returned in case of error? *)
val write :
  ?send_handle:[< `TCP | `Pipe ] t ->
  _ t ->
  Bigstring.t list ->
  ((unit, Error.t) Result.result -> int -> unit) ->
    unit

val try_write : _ t -> Bigstring.t list -> (int, Error.t) Result.result
val is_readable : _ t -> bool
val is_writable : _ t -> bool
val set_blocking : _ t -> bool -> (unit, Error.t) Result.result

(**/**)

module Connect_request :
sig
  type t = [ `Connect ] Request.t
  val make : unit -> t
  val trampoline :
    (C.Types.Stream.Connect_request.t Ctypes.ptr -> int -> unit)
      Ctypes.static_funptr
end

val allocate : ('kind C.Types.Stream.t) Ctypes.typ -> 'kind t
val coerce : _ t -> [ `Base ] t
