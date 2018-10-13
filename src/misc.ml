module Domain =
struct
  include C.Types.Domain
  type t = int
end

module Sockaddr =
struct
  let ocaml_to_c address =
    let c_sockaddr = Ctypes.make C.Types.Sockaddr.union in
    let c_sockaddr_length = Ctypes.(allocate int) 0 in
    C.Functions.Sockaddr.ocaml_to_c
      address (Ctypes.addr c_sockaddr) c_sockaddr_length;
    let c_sockaddr = Ctypes.getf c_sockaddr C.Types.Sockaddr.s_gen in
    c_sockaddr
end
