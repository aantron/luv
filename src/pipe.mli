(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `Pipe ] Stream.t

module Mode :
sig
  type t

  val readable : t
  val writable : t

  val (lor) : t -> t -> t
end

(* DOC Document that the pipe is not yet usable at this point. *)
val init :
  ?loop:Loop.t -> ?for_handle_passing:bool -> unit -> (t, Error.t) Result.result
val open_ : t -> File.t -> (unit, Error.t) Result.result
val bind : t -> string -> (unit, Error.t) Result.result
val connect : t -> string -> ((unit, Error.t) Result.result -> unit) -> unit
val getsockname : t -> (string, Error.t) Result.result
val getpeername : t -> (string, Error.t) Result.result
val pending_instances : t -> int -> unit
val chmod : t -> Mode.t -> (unit, Error.t) Result.result

(* DOC This absolutely requires documentation to be usable. *)
val receive_handle :
  t -> [
    | `TCP of (TCP.t -> (unit, Error.t) Result.result)
    | `Pipe of (t -> (unit, Error.t) Result.result)
    | `None
  ]

(* DOC Stream.listen is to be used for listening. *)
(* DOC it's not necessary to manually call unlink. close unlinks the file. *)
