module Domain =
struct
  include C.Types.Domain
  type t = int
end

module Buf =
struct
  let bigstrings_to_iovecs bigstrings count =
    let pointers =
      bigstrings
      |> List.map Ctypes.(bigarray_start array1)
      |> Ctypes.(CArray.of_list (ptr char))
      |> Ctypes.CArray.start
    in
    let lengths =
      bigstrings
      |> List.map Bigarray.Array1.dim
      |> Ctypes.(CArray.of_list int)
      |> Ctypes.CArray.start
    in
    C.Functions.Buf.bigstrings_to_iovecs pointers lengths count
end

module Sockaddr =
struct
  external get_sockaddr : Unix.sockaddr -> nativeint -> int =
    "luv_get_sockaddr"

  let ocaml_to_c address =
    let c_sockaddr = Ctypes.make C.Types.Sockaddr.union in
    let c_storage = Ctypes.(raw_address_of_ptr (to_voidp (addr c_sockaddr))) in
    ignore (get_sockaddr address c_storage);
    let c_sockaddr = Ctypes.getf c_sockaddr C.Types.Sockaddr.s_gen in
    c_sockaddr

  external alloc_sockaddr : nativeint -> int -> Unix.sockaddr =
    "luv_alloc_sockaddr"

  let c_to_ocaml address length =
    let c_storage = Ctypes.(raw_address_of_ptr (to_voidp (addr address))) in
    alloc_sockaddr c_storage length
end
