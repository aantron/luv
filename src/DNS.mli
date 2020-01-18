(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Addr_info :
sig
  module Request :
  sig
    type t = [ `Getaddrinfo ] Request.t
    val make : unit -> t
  end

  module Flag :
  sig
    type t = [
      | `PASSIVE
      | `CANONNAME
      | `NUMERICHOST
      | `NUMERICSERV
      | `V4MAPPED
      | `ALL
      | `ADDRCONFIG
    ]
  end

  type t = {
    family : Misc.Address_family.t;
    socktype : Misc.Socket_type.t;
    protocol : int;
    addr : Misc.Sockaddr.t;
    canonname : string option;
  }
end

module Name_info :
sig
  module Request :
  sig
    type t = [ `Getnameinfo ] Request.t
    val make : unit -> t
  end

  module Flag :
  sig
    type t = [
      | `NAMEREQD
      | `DGRAM
      | `NOFQDN
      | `NUMERICHOST
      | `NUMERICSERV
    ]
  end
end

(* DOC Examples absolutely necessary. *)

val getaddrinfo :
  ?loop:Loop.t ->
  ?request:Addr_info.Request.t ->
  ?family:Misc.Address_family.t ->
  ?socktype:Misc.Socket_type.t ->
  ?protocol:int ->
  ?flags:Addr_info.Flag.t list ->
  ?node:string ->
  ?service:string ->
  unit ->
  ((Addr_info.t list, Error.t) result -> unit) ->
    unit

val getnameinfo :
  ?loop:Loop.t ->
  ?request:Name_info.Request.t ->
  ?flags:Name_info.Flag.t list ->
  Misc.Sockaddr.t ->
  ((string * string, Error.t) result -> unit) ->
    unit
