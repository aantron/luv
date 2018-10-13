type t = [ `TCP ] Stream.t

let init ?loop ?(domain : Misc.Domain.t option) () =
  let tcp =
    Handle.allocate
      ~callback_count:C.Types.Stream.callback_count C.Types.TCP.t
  in
  let loop = Loop.or_default loop in
  let c_tcp = Handle.c tcp in
  let result =
    match domain with
    | None -> C.Functions.TCP.init loop c_tcp
    | Some domain ->
      C.Functions.TCP.init_ex loop c_tcp (Unsigned.UInt.of_int (domain :> int))
  in
  Error.to_result tcp result

let nodelay tcp yes =
  C.Functions.TCP.nodelay (Handle.c tcp) yes

let keepalive tcp maybe =
  match maybe with
  | None ->
    C.Functions.TCP.keepalive (Handle.c tcp) false 0
  | Some seconds ->
    C.Functions.TCP.keepalive (Handle.c tcp) true seconds

let simultaneous_accepts tcp yes =
  C.Functions.TCP.simultaneous_accepts (Handle.c tcp) yes

let bind ?(flags = []) tcp address =
  let flags =
    match flags with
    | [] -> 0
    | _ -> C.Types.TCP.ipv6_only
  in

  C.Functions.TCP.bind
    (Handle.c tcp) (Ctypes.addr (Misc.Sockaddr.ocaml_to_c address)) flags

let generic_get_name c_function tcp =
  let c_sockaddr = Ctypes.make C.Types.Sockaddr.union in
  let c_sockaddr_length =
    Ctypes.(allocate int) (Ctypes.sizeof C.Types.Sockaddr.union) in

  let result =
    c_function
      (Handle.c tcp)
      (Ctypes.addr (Ctypes.getf c_sockaddr C.Types.Sockaddr.s_gen))
      c_sockaddr_length
  in

  if result <> Error.success then
    Result.Error result
  else begin
    let ocaml_sockaddr =
      C.Functions.Sockaddr.c_to_ocaml
        (Ctypes.addr c_sockaddr) (Ctypes.(!@) c_sockaddr_length) (-1)
    in
    Result.Ok ocaml_sockaddr
  end

let getsockname = generic_get_name C.Functions.TCP.getsockname
let getpeername = generic_get_name C.Functions.TCP.getpeername

let connect tcp address callback =
  let request = Stream.Connect_request.make () in
  Request.set_callback_2 request (fun _request -> callback);
  let immediate_result =
    C.Functions.TCP.connect
      (Request.c request)
      (Handle.c tcp)
      (Ctypes.addr (Misc.Sockaddr.ocaml_to_c address))
      Stream.Connect_request.trampoline
  in
  if immediate_result < Error.success then begin
    Request.clear_callback request;
    callback immediate_result
  end
