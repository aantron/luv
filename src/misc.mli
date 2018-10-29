(* DOC About the libuv mess w.r.t. fd types. *)
(* DOC Link to where the various helpers working on these can be found. *)
module Os_fd :
sig
  type t = C.Types.Os_fd.t
  (* DOC This fails on Windows sockets. *)
  val from_unix : Unix.file_descr -> (t, Error.t) Result.result
  val to_unix : t -> Unix.file_descr
end

module Os_socket :
sig
  type t = C.Types.Os_socket.t
  (* DOC This fails on Windows HANDLEs, probably a complement of
     Os_fd.from_unix. *)
  val from_unix : Unix.file_descr -> (t, Error.t) Result.result
  val to_unix : t -> Unix.file_descr
end

(* TODO Check pid_t, uid_t, gid_t, ... *)

module Domain :
sig
  type t = private int
  val unspec : t
  val inet : t
  val inet6 : t
end

module Sockaddr :
sig
  type t
  val from_unix : Unix.sockaddr -> t
  val to_unix : t -> Unix.sockaddr
end
