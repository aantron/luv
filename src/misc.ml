module Os_fd =
struct
  type t = C.Types.Os_fd.t

  external from_unix_helper : Unix.file_descr -> nativeint -> unit =
    "luv_unix_fd_to_os_fd"

  let from_unix unix_fd =
    let os_fd = Ctypes.make C.Types.Os_fd.t in
    let storage = Ctypes.(raw_address_of_ptr (to_voidp (addr os_fd))) in
    from_unix_helper unix_fd storage;
    if C.Functions.Os_fd.is_invalid_handle_value os_fd then
      Result.Error Error.ebadf
    else
      Result.Ok os_fd

  external to_unix_helper : nativeint -> Unix.file_descr =
    "luv_os_fd_to_unix_fd"

  let to_unix os_fd =
    to_unix_helper (Ctypes.(raw_address_of_ptr (to_voidp (addr os_fd))))
end

module Domain =
struct
  include C.Types.Domain
  type t = int
end

module Buf =
struct
  let bigstrings_to_iovecs bigstrings count =
    let iovecs = Ctypes.CArray.make C.Types.Buf.t count in
    bigstrings |> List.iteri begin fun index bigstring ->
      let iovec = Ctypes.CArray.get iovecs index in
      let base = Ctypes.(bigarray_start array1) bigstring in
      let length = Bigarray.Array1.dim bigstring in
      Ctypes.setf iovec C.Types.Buf.base base;
      Ctypes.setf iovec C.Types.Buf.len (Unsigned.UInt.of_int length)
    end;
    iovecs
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
