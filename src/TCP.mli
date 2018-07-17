open Imports

type tcp
type t = tcp Stream.t

(* TODO Add ?domain argument and use tcp_init_ex internally? Or bind
   tcp_init_ex separately? *)
val init : ?loop:Loop.t ptr -> unit -> (t, Error.Code.t) result
val nodelay : t -> bool -> Error.Code.t
val keepalive : t -> int option -> Error.Code.t
val simultaneous_accepts : t -> bool -> Error.Code.t
val bind : ?flags:[ `IPv6_only ] list -> t -> Unix.sockaddr -> Error.Code.t
(* TODO Docs: the family must be one of the INET families. *)
val getsockname : t -> (Unix.sockaddr, Error.Code.t) result
val getpeername : t -> (Unix.sockaddr, Error.Code.t) result
(* TODO Test getpeername *)
(* TODO Make the request optional? *)
(* TODO Callback memory management. It is stored in the request, not the
   handle. *)
val connect :
  callback:(Stream.Connect_request.t -> Error.Code.t -> unit) ->
  ?request:Stream.Connect_request.t ->
  t ->
  Unix.sockaddr ->
    Error.Code.t

(* TODO _open *)
