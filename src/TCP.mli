(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `TCP ] Stream.t

module Bind_flag :
sig
  type t
  val ipv6only : t
end

val init :
  ?loop:Loop.t -> ?domain:Misc.Address_family.t -> unit ->
    (t, Error.t) Result.result
val nodelay : t -> bool -> Error.t
val open_ : t -> Misc.Os_socket.t -> Error.t
val keepalive : t -> int option -> Error.t
val simultaneous_accepts : t -> bool -> Error.t
val bind : ?flags:Bind_flag.t -> t -> Misc.Sockaddr.t -> Error.t
(* DOC the family must be one of the INET families. *)
val getsockname : t -> (Misc.Sockaddr.t, Error.t) Result.result
val getpeername : t -> (Misc.Sockaddr.t, Error.t) Result.result
val connect : t -> Misc.Sockaddr.t -> (Error.t -> unit) -> unit
val close_reset : t -> (Error.t -> unit) -> unit
