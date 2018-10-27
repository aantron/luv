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
val open_ : t -> File.t -> Error.t (* TODO Test; can test these with just STDERR. *)
val bind : t -> string -> Error.t
val connect : t -> string -> (Error.t -> unit) -> unit
val getsockname : t -> (string, Error.t) Result.result
val getpeername : t -> (string, Error.t) Result.result
val pending_instances : t -> int -> unit
val chmod : t -> Mode.t -> Error.t

val receive_handle :
  t -> [
    | `TCP of TCP.t -> Error.t
    | `Pipe of t -> Error.t
    | `None
  ]

(* DOC Stream.listen is to be used for listening. *)
(* DOC it's not necessary to manually call unlink. close unlinks the file. *)
