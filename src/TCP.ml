type t = [ `TCP ] Stream.t

let init ?loop ?(domain : Misc.Domain.t option) () =
  let tcp : t = Stream.allocate C.Types.TCP.t in
  let loop = Loop.or_default loop in
  let result =
    match domain with
    | None -> C.Functions.TCP.init loop tcp
    | Some domain ->
      C.Functions.TCP.init_ex loop tcp (Unsigned.UInt.of_int (domain :> int))
  in
  Error.to_result tcp result

let open_ =
  C.Functions.TCP.open_

let nodelay =
  C.Functions.TCP.nodelay

let keepalive tcp maybe =
  match maybe with
  | None ->
    C.Functions.TCP.keepalive tcp false 0
  | Some seconds ->
    C.Functions.TCP.keepalive tcp true seconds

let simultaneous_accepts =
  C.Functions.TCP.simultaneous_accepts

let bind ?(flags = []) tcp address =
  let flags =
    match flags with
    | [] -> 0
    | _ -> C.Types.TCP.ipv6_only
  in

  C.Functions.TCP.bind
    tcp (Ctypes.addr (Helpers.Sockaddr.ocaml_to_c address)) flags

let generic_get_name c_function tcp =
  let c_sockaddr = Ctypes.make C.Types.Sockaddr.union in
  let c_sockaddr_length =
    Ctypes.(allocate int) (Ctypes.sizeof C.Types.Sockaddr.union) in

  let result =
    c_function
      tcp
      (Ctypes.addr (Ctypes.getf c_sockaddr C.Types.Sockaddr.s_gen))
      c_sockaddr_length
  in

  if result <> Error.success then
    Result.Error result
  else begin
    let ocaml_sockaddr =
      Helpers.Sockaddr.c_to_ocaml c_sockaddr (Ctypes.(!@) c_sockaddr_length) in
    Result.Ok ocaml_sockaddr
  end

let getsockname = generic_get_name C.Functions.TCP.getsockname
let getpeername = generic_get_name C.Functions.TCP.getpeername

let connect tcp address callback =
  let request = Stream.Connect_request.make () in
  Request.set_callback_2 request (fun _request -> callback);
  let immediate_result =
    C.Functions.TCP.connect
      request
      tcp
      (Ctypes.addr (Helpers.Sockaddr.ocaml_to_c address))
      Stream.Connect_request.trampoline
  in
  if immediate_result < Error.success then begin
    Request.release request;
    callback immediate_result
  end
