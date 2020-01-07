(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type 'kind t = 'kind C.Types.Handle.t Ctypes.ptr

val close : _ t -> unit

val is_active : _ t -> bool
val is_closing : _ t -> bool

val ref : _ t -> unit
val unref : _ t -> unit
val has_ref : _ t -> bool

val send_buffer_size :
  [< `Stream of [< `TCP | `Pipe ] | `UDP ] t -> (int, Error.t) Result.result
val recv_buffer_size :
  [< `Stream of [< `TCP | `Pipe ] | `UDP ] t -> (int, Error.t) Result.result
val set_send_buffer_size :
  [< `Stream of [< `TCP | `Pipe ] | `UDP ] t -> int -> Error.t
val set_recv_buffer_size :
  [< `Stream of [< `TCP | `Pipe ] | `UDP ] t -> int -> Error.t

val fileno :
  [< `Stream of [< `TCP | `Pipe | `TTY ] | `UDP | `Poll ] t ->
    (Misc.Os_fd.t, Error.t) Result.result

val get_loop : _ t -> Loop.t

(**/**)

val allocate :
  ?reference_count:int -> 'kind C.Types.Handle.t Ctypes.typ -> 'kind t
val release : _ t -> unit
val set_reference : ?index:int -> _ t -> _ -> unit
val coerce :
  _ C.Types.Handle.t Ctypes.ptr -> [ `Base ] C.Types.Handle.t Ctypes.ptr

(* DOC warn about memory leak if not calling close. *)
(* DOC after close, the loop must be run. *)
