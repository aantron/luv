(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `TCP ] Stream.t

let init ?loop ?(domain : Misc.Address_family.t option) () =
  let tcp = Stream.allocate C.Types.TCP.t in
  let loop = Loop.or_default loop in
  let result =
    match domain with
    | None ->
      C.Functions.TCP.init loop tcp
    | Some domain ->
      let domain = Misc.Address_family.to_c domain in
      C.Functions.TCP.init_ex loop tcp (Unsigned.UInt.of_int domain)
  in
  Error.to_result tcp result

let open_ tcp socket =
  C.Functions.TCP.open_ tcp socket
  |> Error.to_result ()

let nodelay tcp enable =
  C.Functions.TCP.nodelay tcp enable
  |> Error.to_result ()

let keepalive tcp maybe =
  begin match maybe with
  | None ->
    C.Functions.TCP.keepalive tcp false 0
  | Some seconds ->
    C.Functions.TCP.keepalive tcp true seconds
  end
  |> Error.to_result ()

let simultaneous_accepts tcp enable =
  C.Functions.TCP.simultaneous_accepts tcp enable
  |> Error.to_result ()

let bind ?(ipv6only = false) tcp address =
  let flags = if ipv6only then C.Types.TCP.ipv6only else 0 in
  C.Functions.TCP.bind tcp (Misc.Sockaddr.as_sockaddr address) flags
  |> Error.to_result ()

let getsockname =
  Misc.Sockaddr.wrap_c_getter C.Functions.TCP.getsockname

let getpeername =
  Misc.Sockaddr.wrap_c_getter C.Functions.TCP.getpeername

let connect tcp address callback =
  let request = Stream.Connect_request.make () in
  let wrapped_callback result =
    Error.catch_exceptions callback (Error.to_result () result)
  in
  Request.set_callback request wrapped_callback;
  let immediate_result =
    C.Functions.TCP.connect
      request
      tcp
      (Misc.Sockaddr.as_sockaddr address)
      Stream.Connect_request.trampoline
  in
  if immediate_result < 0 then begin
    Request.release request;
    callback (Error.result_from_c immediate_result)
  end

(* This code closely follows the implementation of close in handle.ml. *)
let close_trampoline =
  C.Functions.Handle.get_close_trampoline ()

let close_reset tcp callback =
  if Handle.is_closing tcp then
    callback (Result.Ok ())
  else begin
    Handle.set_reference
      ~index:C.Types.Handle.close_callback_index
      tcp
      (fun () ->
        Handle.release tcp;
        Error.catch_exceptions callback (Result.Ok ()));
    let immediate_result = C.Functions.TCP.close_reset tcp close_trampoline in
    if immediate_result < 0 then
      callback (Error.result_from_c immediate_result)
  end
