module Addr_info :
sig
  module Request :
  sig
    type t = [ `Getaddrinfo ] Request.t
    val make : unit -> t
  end

  module Flag :
  sig
    type t

    val passive : t
    val canonname : t
    val numerichost : t
    val numericserv : t
    val v4mapped : t
    val all : t
    val addrconfig : t

    val list : t list -> t
    val (lor) : t -> t -> t
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
    type t

    val namereqd : t
    val dgram : t
    val nofqdn : t
    val numerichost : t
    val numericserv : t

    val list : t list -> t
    val (lor) : t -> t -> t
  end
end

(* DOC Examples absolutely necessary. *)

val getaddrinfo :
  ?loop:Loop.t ->
  ?request:Addr_info.Request.t ->
  ?family:Misc.Address_family.t ->
  ?socktype:Misc.Socket_type.t ->
  ?protocol:int ->
  ?flags:Addr_info.Flag.t ->
  ?node:string ->
  ?service:string ->
  ((Addr_info.t list, Error.t) Result.result -> unit) ->
    unit

val getnameinfo :
  ?loop:Loop.t ->
  ?request:Name_info.Request.t ->
  ?flags:Name_info.Flag.t ->
  Misc.Sockaddr.t ->
  ((string * string, Error.t) Result.result -> unit) ->
    unit
