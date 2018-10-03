type t = [ `TCP ] Stream.t

let init =
  Stream.init_tcp

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
    (Handle.c tcp) (Ctypes.addr (Stream.Sockaddr.ocaml_to_c address)) flags

(* TODO Factor common code in these two functions. *)
let getsockname tcp =
  let c_sockaddr = Ctypes.make C.Types.Sockaddr.union in
  let c_sockaddr_length = Ctypes.(allocate int) 0 in

  let result =
    C.Functions.TCP.getsockname
      (Handle.c tcp)
      (Ctypes.addr (Ctypes.getf c_sockaddr C.Types.Sockaddr.s_gen))
      c_sockaddr_length
  in
  if result <> Error.success then
    Result.Error result
  else
    let ocaml_sockaddr =
      C.Functions.Sockaddr.c_to_ocaml
        (Ctypes.addr c_sockaddr) (Ctypes.(!@) c_sockaddr_length) (-1)
    in
    Result.Ok ocaml_sockaddr

let getpeername tcp =
  let c_sockaddr = Ctypes.make C.Types.Sockaddr.union in
  let c_sockaddr_length = Ctypes.(allocate int) 0 in

  let result =
    C.Functions.TCP.getpeername
      (Handle.c tcp)
      (Ctypes.addr (Ctypes.getf c_sockaddr C.Types.Sockaddr.s_gen))
      c_sockaddr_length
  in
  if result <> Error.success then
    Result.Error result
  else
    let ocaml_sockaddr =
      C.Functions.Sockaddr.c_to_ocaml
        (Ctypes.addr c_sockaddr) (Ctypes.(!@) c_sockaddr_length) (-1)
    in
    Result.Ok ocaml_sockaddr

(* TODO Lifetime of the address? Document that we think it doesn't need to be
   retained. *)
(* TODO Lifetime of the handle? Can the handle's close callback be called before
   the connect finishes? Document that it appears the close callback runs only
   after the connect callback, so there is likely no problem. *)
let connect ~callback ?(request = Stream.Connect_request.make ()) tcp address =
  Request.set_callback_2 request callback;
  C.Functions.TCP.connect
    (Request.c request)
    (Handle.c tcp)
    (Ctypes.addr (Stream.Sockaddr.ocaml_to_c address))
    Stream.Trampolines.connect
