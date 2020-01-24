(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module type PROMISE =
sig
  type 'a promise
  val make : unit -> 'a promise * ('a -> unit)
end

module type PROMISIFIED =
sig
  type 'a promise

  module Timer :
  sig
    val delay :
      ?loop:Loop.t ->
      ?call_update_time:bool ->
      int ->
        ((unit, Error.t) result) promise
  end

  module Stream :
  sig
    open Stream

    val shutdown :
      _ t ->
        ((unit, Error.t) result) promise

    val read :
      ?allocate:(int -> Buffer.t) ->
      _ t ->
        (Buffer.t, Error.t) result promise

    val write :
      _ t ->
      Buffer.t list ->
        ((unit, Error.t) result * int) promise
  end

  module TCP :
  sig
    val connect :
      TCP.t ->
      Sockaddr.t ->
        ((unit, Error.t) result) promise
  end

  module File :
  sig
    open File

    val open_ :
      ?loop:Loop.t ->
      ?request:Request.t ->
      ?mode:Mode.t list ->
      string ->
      Open_flag.t list ->
        ((t, Error.t) result) promise

    val close :
      ?loop:Loop.t ->
      ?request:Request.t ->
      t ->
        ((unit, Error.t) result) promise

    val read :
      ?loop:Loop.t ->
      ?request:Request.t ->
      ?offset:int64 ->
      t ->
      Buffer.t list ->
        ((Unsigned.Size_t.t, Error.t) result) promise
  end

  module DNS :
  sig
    open DNS

    val getaddrinfo :
      ?loop:Loop.t ->
      ?request:Addr_info.Request.t ->
      ?family:Sockaddr.Address_family.t ->
      ?socktype:Sockaddr.Socket_type.t ->
      ?protocol:int ->
      ?flags:Addr_info.Flag.t list ->
      ?node:string ->
      ?service:string ->
      unit ->
        ((Addr_info.t list, Error.t) result) promise

    val getnameinfo :
      ?loop:Loop.t ->
      ?request:Name_info.Request.t ->
      ?flags:Name_info.Flag.t list ->
      Sockaddr.t ->
        ((string * string, Error.t) result) promise
  end
end
