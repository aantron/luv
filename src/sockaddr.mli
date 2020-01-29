(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Network address families. See
    {{:http://man7.org/linux/man-pages/man2/socket.2.html#DESCRIPTION}
    [socket(2)]}. *)
module Address_family :
sig
  type t = [
    | `UNSPEC
    | `INET
    | `INET6
    | `OTHER of int
  ]

  (**/**)

  (* Internal functions; do not use. *)

  val to_c : t -> int
  val from_c : int -> t
end

(** Socket types. See
    {{:http://man7.org/linux/man-pages/man2/socket.2.html#DESCRIPTION}
    [socket(2)]}. *)
module Socket_type :
sig
  type t = [
    | `STREAM
    | `DGRAM
    | `RAW
  ]

  (**/**)

  (* Internal functions; do not use. *)

  val to_c : t -> int
  val from_c : int -> t
end

type t
(** Binds {{:http://man7.org/linux/man-pages/man7/ip.7.html#DESCRIPTION}
    [struct sockaddr]}.

    The functions in this module automatically take care of converting between
    network and host byte order. *)

val ipv4 : string -> int -> (t, Error.t) result
(** Converts a string and port number to an IPv4 [struct sockaddr].

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_ip4_addr}
    [uv_ip4_addr]}. *)

val ipv6 : string -> int -> (t, Error.t) result
(** Converts a string and port number to an IPv6 [struct sockaddr].

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_ip6_addr}
    [uv_ip4_addr]}. *)

val to_string : t -> string option
(** Converts a network address to a string.

    Binds either {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_ip4_name}
    [uv_ip4_name]} and
    {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_ip6_name}
    [uv_ip6_name]}. *)

val port : t -> int option
(** Extracts the port in a network address. *)

(**/**)

(* Internal functions; do not use. *)

val copy_storage : C.Types.Sockaddr.storage Ctypes.ptr -> t
val copy_sockaddr : int -> C.Types.Sockaddr.t Ctypes.ptr -> t

val as_sockaddr : t -> C.Types.Sockaddr.t Ctypes.ptr
val null : C.Types.Sockaddr.t Ctypes.ptr

val wrap_c_getter :
  ('handle -> C.Types.Sockaddr.t Ctypes.ptr -> int Ctypes.ptr -> int) ->
  ('handle -> (t, Error.t) result)
