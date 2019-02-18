(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `TCP ] Stream.t

module Bind_flag =
struct
  type t = int
  let ipv6only = C.Types.TCP.ipv6only
end

let init ?loop ?(domain : Misc.Address_family.t option) () =
  let tcp = Stream.allocate C.Types.TCP.t in
  let loop = Loop.or_default loop in
  let result =
    match domain with
    | None ->
      C.Functions.TCP.init loop tcp
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

let bind ?(flags = 0) tcp address =
  C.Functions.TCP.bind tcp (Misc.Sockaddr.as_sockaddr address) flags

let getsockname = Misc.Sockaddr.wrap_c_getter C.Functions.TCP.getsockname
let getpeername = Misc.Sockaddr.wrap_c_getter C.Functions.TCP.getpeername

let connect tcp address callback =
  let request = Stream.Connect_request.make () in
  let callback = Error.catch_exceptions callback in
  Request.set_callback request callback;
  let immediate_result =
    C.Functions.TCP.connect
      request
      tcp
      (Misc.Sockaddr.as_sockaddr address)
      Stream.Connect_request.trampoline
  in
  if immediate_result < Error.success then begin
    Request.release request;
    callback immediate_result
  end
