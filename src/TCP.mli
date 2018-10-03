type t = [ `TCP ] Stream.t

(* TODO Add ?domain argument and use tcp_init_ex internally? Or bind
   tcp_init_ex separately? *)
val init : ?loop:Loop.t -> unit -> (t, Error.t) Result.result
val nodelay : t -> bool -> Error.t
val keepalive : t -> int option -> Error.t
val simultaneous_accepts : t -> bool -> Error.t
val bind : ?flags:[ `IPv6_only ] list -> t -> Unix.sockaddr -> Error.t
(* TODO Docs: the family must be one of the INET families. *)
val getsockname : t -> (Unix.sockaddr, Error.t) Result.result
val getpeername : t -> (Unix.sockaddr, Error.t) Result.result
(* TODO Test getpeername *)
(* TODO Make the request optional? *)
(* TODO Callback memory management. It is stored in the request, not the
   handle. *)
val connect :
  callback:(Stream.Connect_request.t -> Error.t -> unit) ->
  ?request:Stream.Connect_request.t ->
  t ->
  Unix.sockaddr ->
    Error.t

(* TODO _open *)
