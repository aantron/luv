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

module Os_socket =
struct
  type t = C.Types.Os_socket.t

  external from_unix_helper : Unix.file_descr -> nativeint -> unit =
    "luv_unix_fd_to_os_socket"

  let from_unix unix_fd =
    let os_socket = Ctypes.make C.Types.Os_socket.t in
    let storage = Ctypes.(raw_address_of_ptr (to_voidp (addr os_socket))) in
    from_unix_helper unix_fd storage;
    if C.Functions.Os_socket.is_invalid_socket_value os_socket then
      Result.Error Error.ebadf
    else
      Result.Ok os_socket

  external to_unix_helper : nativeint -> Unix.file_descr =
    "luv_os_socket_to_unix_fd"

  let to_unix os_socket =
    to_unix_helper (Ctypes.(raw_address_of_ptr (to_voidp (addr os_socket))))
end

module Domain =
struct
  include C.Types.Domain
  type t = int
end

module Sockaddr =
struct
  type t = Unix.sockaddr
  let from_unix address = address
  let to_unix address = address
end
