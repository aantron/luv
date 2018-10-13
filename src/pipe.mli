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
val open_ : t -> File.t -> Error.t (* TODO Test *)
val bind : t -> string -> Error.t
val connect : t -> string -> (Error.t -> unit) -> unit
val getsockname : t -> (string, Error.t) Result.result
val getpeername : t -> (string, Error.t) Result.result
val pending_instances : t -> int -> unit
(* TODO Does this call fail? *)
val pending_count : t -> int
(* TODO Need to expose handle types for this. *)
val pending_type : t -> unit
val chmod : t -> Mode.t -> Error.t

(* DOC Stream.listen is to be used for listening. *)
(* DOC it's not necessary to manually call unlink. close unlinks the file. *)
(* TODO Test the above. *)
