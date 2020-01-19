(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** DNS queries.

    This module exposes two main functions, {!Luv.DNS.getaddrinfo} and
    {!Luv.DNS.getnameinfo}. Both take an optional request object. By default,
    Luv allocates and manages request objects internally. However, a
    user-provided request object allows the user to cancel requests using
    {!Luv.Request.cancel}.

    See {!Luv.File} for a similar API with more detailed discussion. *)

(** Binds
    {{:http://man7.org/linux/man-pages/man3/getaddrinfo.3.html#DESCRIPTION}
    [struct addrinfo]} and request objects for {!Luv.DNS.getaddrinfo}. *)
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

(** Optional flags and request objects for use with {!Luv.DNS.getnameinfo}. *)
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
(** Retrieves addresses.

    Binds {{:http://docs.libuv.org/en/v1.x/dns.html#c.uv_getaddrinfo}
    [uv_getaddrinfo]}. See
    {{:http://man7.org/linux/man-pages/man3/getaddrinfo.3.html}
    [getaddrinfo(3)]}.

    [uv_getaddrinfo] and [getaddrinfo(3)] take optional hints in fields of an
    argument of type [struct addrinfo]. {!Luv.DNS.getaddrinfo} instead has
    several optional arguments, each named after one of the fields of
    [hints]. *)

val getnameinfo :
  ?loop:Loop.t ->
  ?request:Name_info.Request.t ->
  ?flags:Name_info.Flag.t list ->
  Misc.Sockaddr.t ->
  ((string * string, Error.t) result -> unit) ->
    unit
(** Retrieves host names.

    Binds {{:http://docs.libuv.org/en/v1.x/dns.html#c.uv_getnameinfo}
    [uv_getnameinfo]}. See
    {{:http://man7.org/linux/man-pages/man3/getnameinfo.3.html}
    [getnameinfo(3)]}. *)
