(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Addr_info =
struct
  module Request =
  struct
    type t = [ `Getaddrinfo ] Request.t

    let make () =
      Request.allocate C.Types.DNS.Getaddrinfo.t
  end

  module Flag =
  struct
    type t = [
      | `PASSIVE
      | `CANONNAME
      | `NUMERICHOST
      | `NUMERICSERV
      | `V4MAPPED
      | `ALL
      | `ADDRCONFIG
    ]

    let to_c = let open C.Types.DNS.Getaddrinfo.Flag in function
      | `PASSIVE -> passive
      | `CANONNAME -> canonname
      | `NUMERICHOST -> numerichost
      | `NUMERICSERV -> numericserv
      | `V4MAPPED -> v4mapped
      | `ALL -> all
      | `ADDRCONFIG -> addrconfig
  end

  type t = {
    family : Misc.Sockaddr.Address_family.t;
    socktype : Misc.Sockaddr.Socket_type.t;
    protocol : int;
    addr : Misc.Sockaddr.t;
    canonname : string option;
  }
end

module Name_info =
struct
  module Request =
  struct
    type t = [ `Getnameinfo ] Request.t

    let make () =
      Request.allocate C.Types.DNS.Getnameinfo.t
  end

  module Flag =
  struct
    type t = [
      | `NAMEREQD
      | `DGRAM
      | `NOFQDN
      | `NUMERICHOST
      | `NUMERICSERV
    ]

    let to_c = let open C.Types.DNS.Getnameinfo.Flag in function
      | `NAMEREQD -> namereqd
      | `DGRAM -> dgram
      | `NOFQDN -> nofqdn
      | `NUMERICHOST -> numerichost
      | `NUMERICSERV -> numericserv
  end
end

let rec addrinfo_list_to_ocaml addrinfo =
  if Ctypes.is_null addrinfo then
    []
  else begin
    let module AI = C.Types.DNS.Addrinfo in
    let addrinfo = Ctypes.(!@) addrinfo in
    let family =
      Misc.Sockaddr.Address_family.from_c (Ctypes.getf addrinfo AI.family) in
    let socktype =
      Misc.Sockaddr.Socket_type.from_c (Ctypes.getf addrinfo AI.socktype) in
    let addr =
      Misc.Sockaddr.copy_sockaddr
        (Ctypes.getf addrinfo AI.addr) (Ctypes.getf addrinfo AI.addrlen)
    in
    let ocaml_addrinfo = {
      Addr_info.family;
      socktype;
      protocol = Ctypes.getf addrinfo AI.protocol;
      addr;
      canonname = Ctypes.getf addrinfo AI.canonname;
    }
    in
    let next = Ctypes.getf addrinfo AI.next in
    ocaml_addrinfo::(addrinfo_list_to_ocaml next)
  end

module Async =
struct
  let getaddrinfo_trampoline =
    C.Functions.DNS.Getaddrinfo.get_trampoline ()

  let getaddrinfo
      ?loop
      ?(request = Addr_info.Request.make ())
      ?family
      ?socktype
      ?protocol
      ?flags
      ?node
      ?service
      ()
      callback =

    let loop = Loop.or_default loop in

    let hints =
      let module AI = C.Types.DNS.Addrinfo in
      match family, socktype, protocol, flags with
      | None, None, None, None ->
        Ctypes.(from_voidp AI.t null)
      | _ ->
        let hints = Ctypes.make AI.t in
        let family =
          match family with
          | Some family -> family
          | None -> `UNSPEC
        in
        let family = Misc.Sockaddr.Address_family.to_c family in
        Ctypes.setf hints AI.family family;
        begin match socktype with
        | Some socktype ->
          let socktype = Misc.Sockaddr.Socket_type.to_c socktype in
          Ctypes.setf hints AI.socktype socktype
        | None -> ()
        end;
        begin match protocol with
        | Some protocol -> Ctypes.setf hints AI.protocol protocol
        | None -> ()
        end;
        begin match flags with
        | Some flags ->
          let flags = Helpers.Bit_field.list_to_c Addr_info.Flag.to_c flags in
          Ctypes.setf hints AI.flags flags
        | None -> ()
        end;
        Ctypes.addr hints
    in

    let callback = Error.catch_exceptions callback in
    Request.set_callback request begin fun result ->
      result
      |> Error.to_result_lazy begin fun () ->
        let addrinfos =
          Ctypes.(getf (!@ request)) C.Types.DNS.Getaddrinfo.addrinfo in
        let result = addrinfo_list_to_ocaml addrinfos in
        C.Functions.DNS.Getaddrinfo.free addrinfos;
        result
      end
      |> callback
    end;

    let immediate_result =
      C.Functions.DNS.Getaddrinfo.getaddrinfo
        loop request getaddrinfo_trampoline node service hints
    in

    if immediate_result < 0 then begin
      Request.release request;
      callback (Error.result_from_c immediate_result)
    end

  let load_string request field' field_length =
    let bigstring =
      Ctypes.(bigarray_of_ptr
        array1 field_length Bigarray.Char (request |-> field'))
    in
    let rec find_terminator index =
      if Buffer.unsafe_get bigstring index = '\000' then index
      else find_terminator (index + 1)
    in
    Buffer.sub bigstring ~offset:0 ~length:(find_terminator 0)
    |> Buffer.to_string

  let getnameinfo_trampoline =
    C.Functions.DNS.Getnameinfo.get_trampoline ()

  let getnameinfo
      ?loop
      ?(request = Name_info.Request.make ())
      ?(flags = [])
      address
      callback =

    let callback = Error.catch_exceptions callback in
    Request.set_callback request begin fun result ->
      result
      |> Error.to_result_lazy begin fun () ->
        let module NI = C.Types.DNS.Getnameinfo in
        let host = load_string request NI.host NI.maxhost in
        let service = load_string request NI.service NI.maxserv in
        (host, service)
      end
      |> callback
    end;

    let flags = Helpers.Bit_field.list_to_c Name_info.Flag.to_c flags in

    let immediate_result =
      C.Functions.DNS.Getnameinfo.getnameinfo
        (Loop.or_default loop)
        request
        getnameinfo_trampoline
        (Misc.Sockaddr.as_sockaddr address)
        flags
    in

    if immediate_result < 0 then begin
      Request.release request;
      callback (Error.result_from_c immediate_result)
    end
end

include Async
