(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Address_family =
struct
  type t = [
    | `UNSPEC
    | `INET
    | `INET6
    | `OTHER of int
  ]

  let to_c = let open C.Types.Address_family in function
    | `UNSPEC -> unspec
    | `INET -> inet
    | `INET6 -> inet6
    | `OTHER i -> i

  let from_c = let open C.Types.Address_family in function
    | family when family = unspec -> `UNSPEC
    | family when family = inet -> `INET
    | family when family = inet6 -> `INET6
    | family -> `OTHER family
end

module Socket_type =
struct
  type t = [
    | `STREAM
    | `DGRAM
    | `RAW
    | `OTHER of int
  ]

  let to_c = let open C.Types.Socket_type in function
    | `STREAM -> stream
    | `DGRAM -> dgram
    | `RAW -> raw
    | `OTHER i -> i

  let from_c = let open C.Types.Socket_type in function
    | socket_type when socket_type = stream -> `STREAM
    | socket_type when socket_type = dgram -> `DGRAM
    | socket_type when socket_type = raw -> `RAW
    | socket_type -> `OTHER socket_type
end

type t = C.Types.Sockaddr.storage

let make () =
  Ctypes.make C.Types.Sockaddr.storage

let as_sockaddr address =
  Ctypes.(coerce
    (ptr C.Types.Sockaddr.storage) (ptr C.Types.Sockaddr.t) (addr address))

let null =
  Ctypes.(from_voidp C.Types.Sockaddr.t null)

let as_in address =
  Ctypes.(coerce
    (ptr C.Types.Sockaddr.storage) (ptr C.Types.Sockaddr.in_) (addr address))

let as_in6 address =
  Ctypes.(coerce
    (ptr C.Types.Sockaddr.storage) (ptr C.Types.Sockaddr.in6) (addr address))

let from_string c_function coerce ip port =
  let storage = make () in
  c_function (Ctypes.ocaml_string_start ip) port (coerce storage)
  |> Error.to_result storage

let ipv4 = from_string C.Functions.Sockaddr.ip4_addr as_in
let ipv6 = from_string C.Functions.Sockaddr.ip6_addr as_in6

let finish_to_string c_function coerce storage =
  let buffer_size = 64 in
  let buffer = Bytes.create buffer_size in
  c_function
    (coerce storage)
    (Ctypes.ocaml_bytes_start buffer)
    (Unsigned.Size_t.of_int buffer_size)
  |> ignore;
  let length = Bytes.index buffer '\000' in
  Some (Bytes.sub_string buffer 0 length)

let to_string storage =
  let family =
    Ctypes.getf storage C.Types.Sockaddr.family
    |> Address_family.from_c
  in
  if family = `INET then
    finish_to_string C.Functions.Sockaddr.ip4_name as_in storage
  else if family = `INET6 then
    finish_to_string C.Functions.Sockaddr.ip6_name as_in6 storage
  else
    None

let finish_to_port network_order_port =
  Some (C.Functions.Sockaddr.ntohs network_order_port)

let port storage =
  let family =
    Ctypes.getf storage C.Types.Sockaddr.family
    |> Address_family.from_c
  in
  if family = `INET then
    finish_to_port
      (Ctypes.(getf (!@ (as_in storage)) C.Types.Sockaddr.sin_port))
  else if family = `INET6 then
    finish_to_port
      (Ctypes.(getf (!@ (as_in6 storage)) C.Types.Sockaddr.sin6_port))
  else
    None

let copy_storage address =
  let storage = make () in
  Ctypes.(addr storage <-@ !@ address);
  storage

let copy_sockaddr length address =
  let storage = make () in
  C.Functions.Sockaddr.memcpy_from_sockaddr
    (Ctypes.addr storage) address length;
  storage

let wrap_c_getter c_function handle =
  let storage = make () in
  let length =
    Ctypes.(allocate int) (Ctypes.sizeof C.Types.Sockaddr.storage) in
  c_function handle (as_sockaddr storage) length
  |> Error.to_result storage
