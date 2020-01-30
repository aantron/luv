(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Fd :
sig
  type t = C.Types.Os_fd.t
  (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_fd_t}}. *)
end

module Socket :
sig
  type t = C.Types.Os_socket.t
  (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_sock_t}}. *)
end
