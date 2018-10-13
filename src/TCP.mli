type t = [ `TCP ] Stream.t

val init :
  ?loop:Loop.t -> ?domain:Misc.Domain.t -> unit -> (t, Error.t) Result.result
val nodelay : t -> bool -> Error.t
val keepalive : t -> int option -> Error.t
val simultaneous_accepts : t -> bool -> Error.t
val bind : ?flags:[ `IPv6_only ] list -> t -> Unix.sockaddr -> Error.t
(* DOC the family must be one of the INET families. *)
val getsockname : t -> (Unix.sockaddr, Error.t) Result.result
val getpeername : t -> (Unix.sockaddr, Error.t) Result.result
val connect : t -> Unix.sockaddr -> (Error.t -> unit) -> unit

(* TODO _open *)
