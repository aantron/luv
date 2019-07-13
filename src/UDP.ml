(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `UDP ] Handle.t

module Bind_flag =
struct
  include C.Types.UDP.Flag
  include Helpers.Bit_flag
end

module Membership =
struct
  include C.Types.UDP.Membership
  type t = int
end

let init ?loop ?(domain : Misc.Address_family.t option) () =
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
      C.Functions.UDP.init_ex loop udp (Unsigned.UInt.of_int (domain :> int))
  in
  Error.to_result udp result

let open_ =
  C.Functions.UDP.open_

let bind ?(flags = 0) udp address =
  C.Functions.UDP.bind udp (Misc.Sockaddr.as_sockaddr address) flags

let getsockname = Misc.Sockaddr.wrap_c_getter C.Functions.UDP.getsockname

let set_membership udp ~group ~interface membership =
  C.Functions.UDP.set_membership
    udp
    (Ctypes.ocaml_string_start group)
    (Ctypes.ocaml_string_start interface)
    membership

let set_multicast_loop =
  C.Functions.UDP.set_multicast_loop

let set_multicast_ttl =
  C.Functions.UDP.set_multicast_ttl

let set_multicast_interface udp interface =
  C.Functions.UDP.set_multicast_interface
    udp (Ctypes.ocaml_string_start interface)

let set_ttl =
  C.Functions.UDP.set_ttl

let send_trampoline =
  C.Functions.UDP.Send_request.get_trampoline ()

let send_general udp buffers address callback =
  let count = List.length buffers in
  let iovecs = Helpers.Buf.bigstrings_to_iovecs buffers count in

  let request = Request.allocate C.Types.UDP.Send_request.t in

  let callback = Error.catch_exceptions callback in
  Request.set_callback request begin fun result ->
    let module Sys = Compatibility.Sys in
    ignore (Sys.opaque_identity buffers);
    ignore (Sys.opaque_identity iovecs);
    callback result
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

  if immediate_result < Error.success then begin
    Request.release request;
    callback immediate_result
  end

let send udp buffers address callback =
  send_general udp buffers (Misc.Sockaddr.as_sockaddr address) callback

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

  Error.clamp result

let try_send udp buffers address =
  try_send_general udp buffers (Misc.Sockaddr.as_sockaddr address)

let alloc_trampoline =
  C.Functions.Handle.get_alloc_trampoline ()

let recv_trampoline =
  C.Functions.UDP.get_recv_trampoline ()

let recv_start
    ?(allocate = Bigstring.create) ?(buffer_not_used = ignore) udp callback =

  let last_allocated_buffer = ref None in

  let callback = Error.catch_exceptions callback in
  Handle.set_reference udp
      begin fun (nread_or_error : Error.t) sockaddr flags ->

    let maybe_buffer = !last_allocated_buffer in
    last_allocated_buffer := None;

    if (nread_or_error :> int) < 0 then
      callback (Result.Error nread_or_error)

    else if sockaddr = Nativeint.zero then
      buffer_not_used ()

    else begin
      let length = (nread_or_error :> int) [@ocaml.warning "-18"] in
      let buffer =
        match maybe_buffer with
        | Some buffer -> buffer
        | None -> assert false
      in
      let buffer = Bigstring.sub buffer ~offset:0 ~length in
      let sockaddr =
        sockaddr
        |> Ctypes.ptr_of_raw_address
        |> Ctypes.from_voidp C.Types.Sockaddr.storage
        |> Misc.Sockaddr.copy_storage
      in
      let truncated = (flags = C.Types.UDP.Flag.partial) in
      callback (Result.Ok (buffer, sockaddr, truncated))
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
  if immediate_result < Error.success then
    callback (Result.Error immediate_result)

let recv_stop =
  C.Functions.UDP.recv_stop

let get_send_queue_size udp =
  C.Functions.UDP.get_send_queue_size udp
  |> Unsigned.Size_t.to_int

let get_send_queue_count udp =
  C.Functions.UDP.get_send_queue_count udp
  |> Unsigned.Size_t.to_int

module Connected =
struct
  let connect udp address =
    C.Functions.UDP.connect udp (Misc.Sockaddr.as_sockaddr address)

  let disconnect udp =
    C.Functions.UDP.connect udp Misc.Sockaddr.null

  let getpeername = Misc.Sockaddr.wrap_c_getter C.Functions.UDP.getpeername

  let send udp buffers callback =
    send_general udp buffers Misc.Sockaddr.null callback

  let try_send udp buffers =
    try_send_general udp buffers Misc.Sockaddr.null
end
