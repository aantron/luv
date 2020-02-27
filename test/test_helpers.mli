(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



val check_success_result : string -> ('a, Luv.Error.t) result -> 'a
val check_error_result :
  string -> Luv.Error.t -> (_, Luv.Error.t) result -> unit
val check_error_code : string -> Luv.Error.t -> Luv.Error.t -> unit

val check_not_null : string -> _ Ctypes.ptr -> unit
val check_pointer : string -> 'a Ctypes.ptr -> 'a Ctypes.ptr -> unit

val check_directory_entries :
  string -> string list -> Luv.File.Dirent.t list -> unit

val make_callback : unit -> (_ -> unit)
val no_memory_leak : ?base_repetitions:int -> (int -> unit) -> unit

val default_loop : Luv.Loop.t
val run : ?with_timeout:bool -> unit -> unit

val port : unit -> int
val fresh_address : unit -> Luv.Sockaddr.t

val check_exception : exn -> (unit -> unit) -> unit

(* A simplistic synchronization primitive, used for controlling the order of
   callback calls in some places in the tester. *)
type event
val event : unit -> event
val defer : event -> (unit -> unit) -> unit
val proceed : event -> unit

val in_travis : bool
