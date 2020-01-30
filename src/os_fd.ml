(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Fd =
struct
  type t = C.Types.Os_fd.t
end

module Socket =
struct
  type t = C.Types.Os_socket.t
end
