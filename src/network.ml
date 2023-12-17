(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Interface_address =
struct
  type t = {
    name : string;
    is_internal : bool;
    physical : string;
    address : Sockaddr.t;
    netmask : Sockaddr.t;
  }

  let c_sockaddr_length =
    Ctypes.(max (sizeof C.Types.Sockaddr.in_) (sizeof C.Types.Sockaddr.in6))
end

let load_address value =
  Ctypes.(coerce
    (ptr C.Types.Sockaddr.in_) (ptr C.Types.Sockaddr.t) (addr value))
  |> Sockaddr.copy_sockaddr Interface_address.c_sockaddr_length

let interface_addresses () =
  let module IA = C.Types.Network.Interface_address in

  let null = Ctypes.(from_voidp IA.t null) in
  let interfaces = Ctypes.(allocate (ptr IA.t)) null in
  let count = Ctypes.(allocate int) 0 in

  C.Functions.Network.interface_addresses interfaces count
  |> Error.to_result_f begin fun () ->
    let interfaces = Ctypes.(!@) interfaces in
    let count = Ctypes.(!@) count in

    let rec convert index =
      if index >= count then
        []
      else begin
        let c_interface = Ctypes.(!@ (interfaces +@ index)) in
        let physical = Ctypes.getf c_interface IA.phys_addr in
        let interface = Interface_address.{
          name = Ctypes.getf c_interface IA.name;
          is_internal = Ctypes.getf c_interface IA.is_internal;
          physical = String.init 6 (Ctypes.CArray.get physical);
          address = load_address (Ctypes.getf c_interface IA.address4);
          netmask = load_address (Ctypes.getf c_interface IA.netmask4);
        }
        in
        interface::(convert (index + 1))
      end
    in
    let converted_interfaces = convert 0 in
    C.Functions.Network.free_interface_addresses interfaces count;
    converted_interfaces
  end

let generic_toname c_function index =
  let length = C.Types.Network.if_namesize in
  let buffer = Bytes.create length in
  c_function
    (Unsigned.UInt.of_int index)
    (Ctypes.ocaml_bytes_start buffer)
    (Ctypes.(allocate size_t) (Unsigned.Size_t.of_int length))
  |> Error.to_result_f begin fun () ->
    let length = Bytes.index buffer '\000' in
    Bytes.sub_string buffer 0 length
  end

let if_indextoname = generic_toname C.Functions.Network.if_indextoname
let if_indextoiid = generic_toname C.Functions.Network.if_indextoiid

let gethostname () =
  let length = C.Types.Network.maxhostnamesize in
  let buffer = Bytes.create length in
  C.Functions.Network.gethostname
    (Ctypes.ocaml_bytes_start buffer)
    (Ctypes.(allocate size_t) (Unsigned.Size_t.of_int length))
  |> Error.to_result_f begin fun () ->
    let length = Bytes.index buffer '\000' in
    Bytes.sub_string buffer 0 length
  end
