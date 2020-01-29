(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `UDP ] Handle.t

module Membership = C.Types.UDP.Membership

let init ?loop ?domain () =
  let udp =
    Handle.allocate
      C.Types.UDP.t ~reference_count:C.Types.UDP.reference_count
  in
  let loop = Loop.or_default loop in
  let result =
    match domain with
    | None ->
      C.Functions.UDP.init loop udp
    | Some domain ->
      let domain = Sockaddr.Address_family.to_c domain in
      C.Functions.UDP.init_ex loop udp (Unsigned.UInt.of_int domain)
  in
  Error.to_result udp result

let open_ udp socket =
  C.Functions.UDP.open_ udp socket
  |> Error.to_result ()

let bind ?(ipv6only = false) ?(reuseaddr = false) udp address =
  let flags =
    let accumulate = Helpers.Bit_field.accumulate in
    0
    |> accumulate C.Types.UDP.Flag.ipv6only ipv6only
    |> accumulate C.Types.UDP.Flag.reuseaddr reuseaddr
  in
  C.Functions.UDP.bind udp (Sockaddr.as_sockaddr address) flags
  |> Error.to_result ()

let getsockname =
  Sockaddr.wrap_c_getter C.Functions.UDP.getsockname

let set_membership udp ~group ~interface membership =
  C.Functions.UDP.set_membership
    udp
    (Ctypes.ocaml_string_start group)
    (Ctypes.ocaml_string_start interface)
    membership
  |> Error.to_result ()

let set_source_membership udp ~group ~interface ~source membership =
  C.Functions.UDP.set_source_membership
    udp
    (Ctypes.ocaml_string_start group)
    (Ctypes.ocaml_string_start interface)
    (Ctypes.ocaml_string_start source)
    membership
  |> Error.to_result ()

let set_multicast_loop udp on =
  C.Functions.UDP.set_multicast_loop udp on
  |> Error.to_result ()

let set_multicast_ttl udp ttl =
  C.Functions.UDP.set_multicast_ttl udp ttl
  |> Error.to_result ()

let set_multicast_interface udp interface =
  C.Functions.UDP.set_multicast_interface
    udp (Ctypes.ocaml_string_start interface)
  |> Error.to_result ()

let set_broadcast udp on =
  C.Functions.UDP.set_broadcast udp on
  |> Error.to_result ()

let set_ttl udp ttl =
  C.Functions.UDP.set_ttl udp ttl
  |> Error.to_result ()

let send_trampoline =
  C.Functions.UDP.Send_request.get_trampoline ()

let send_general udp buffers address callback =
  let count = List.length buffers in
  let iovecs = Helpers.Buf.bigstrings_to_iovecs buffers count in

  let request = Request.allocate C.Types.UDP.Send_request.t in

  Request.set_callback request begin fun result ->
    let module Sys = Compatibility.Sys in
    ignore (Sys.opaque_identity buffers);
    ignore (Sys.opaque_identity iovecs);
    Error.catch_exceptions callback (Error.to_result () result)
  end;

  let immediate_result =
    C.Functions.UDP.send
      request
      udp
      (Ctypes.CArray.start iovecs)
      (Unsigned.UInt.of_int count)
      address
      send_trampoline
  in

  if immediate_result < 0 then begin
    Request.release request;
    callback (Error.result_from_c immediate_result)
  end

let send udp buffers address callback =
  send_general udp buffers (Sockaddr.as_sockaddr address) callback

let try_send_general udp buffers address =
  let count = List.length buffers in
  let iovecs = Helpers.Buf.bigstrings_to_iovecs buffers count in

  let result =
    C.Functions.UDP.try_send
      udp
      (Ctypes.CArray.start iovecs)
      (Unsigned.UInt.of_int count)
      address
  in

  let module Sys = Compatibility.Sys in
  ignore (Sys.opaque_identity buffers);
  ignore (Sys.opaque_identity iovecs);

  Error.to_result () result

let try_send udp buffers address =
  try_send_general udp buffers (Sockaddr.as_sockaddr address)

module Recv_flag =
struct
  type t = [
    | `PARTIAL
  ]
end

let alloc_trampoline =
  C.Functions.Handle.get_alloc_trampoline ()

let recv_trampoline =
  C.Functions.UDP.get_recv_trampoline ()

let recv_start ?(allocate = Buffer.create) udp callback =
  let last_allocated_buffer = ref None in

  Handle.set_reference udp begin fun nread_or_error sockaddr flags ->
    let maybe_buffer = !last_allocated_buffer in
    last_allocated_buffer := None;

    if nread_or_error < 0 then
      callback (Error.result_from_c nread_or_error)

    else begin
      let length = nread_or_error in
      let buffer =
        match maybe_buffer with
        | Some buffer -> buffer
        | None -> assert false
      in
      let buffer =
        if Buffer.size buffer <= length then
          buffer
        else
          Buffer.sub buffer ~offset:0 ~length
      in
      let sockaddr =
        if sockaddr = Nativeint.zero then
          None
        else
          sockaddr
          |> Ctypes.ptr_of_raw_address
          |> Ctypes.from_voidp C.Types.Sockaddr.storage
          |> Sockaddr.copy_storage
          |> fun sockaddr -> Some sockaddr
      in
      let flags =
        if flags land C.Types.UDP.Flag.partial = 0 then
          []
        else
          [`PARTIAL]
      in
      Error.catch_exceptions callback (Result.Ok (buffer, sockaddr, flags))
    end
  end;

  Handle.set_reference udp ~index:C.Types.UDP.allocate_callback_index
      begin fun suggested_size ->

    let buffer = allocate suggested_size in
    last_allocated_buffer := Some buffer;
    buffer
  end;

  let immediate_result =
    C.Functions.UDP.recv_start udp alloc_trampoline recv_trampoline in
  if immediate_result < 0 then
    callback (Error.result_from_c immediate_result)

let recv_stop udp =
  C.Functions.UDP.recv_stop udp
  |> Error.to_result ()

let get_send_queue_size udp =
  C.Functions.UDP.get_send_queue_size udp
  |> Unsigned.Size_t.to_int

let get_send_queue_count udp =
  C.Functions.UDP.get_send_queue_count udp
  |> Unsigned.Size_t.to_int

module Connected =
struct
  let connect udp address =
    C.Functions.UDP.connect udp (Sockaddr.as_sockaddr address)
    |> Error.to_result ()

  let disconnect udp =
    C.Functions.UDP.connect udp Sockaddr.null
    |> Error.to_result ()

  let getpeername = Sockaddr.wrap_c_getter C.Functions.UDP.getpeername

  let send udp buffers callback =
    send_general udp buffers Sockaddr.null callback

  let try_send udp buffers =
    try_send_general udp buffers Sockaddr.null
end
