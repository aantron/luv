(* DOC About the libuv mess w.r.t. fd types. *)
(* DOC Link to where the various helpers working on these can be found. *)
module Os_fd :
sig
  type t = C.Types.Os_fd.t
  (* DOC This fails on Windows sockets. *)
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

(**/**)

(* TODO Move modules like these out to a separate file that is not exposed to
   the outside world through luv.ml. *)

module Buf :
sig
  val bigstrings_to_iovecs :
    Bigstring.t list -> int -> C.Types.Buf.t Ctypes.carray
end

module Sockaddr :
sig
  val ocaml_to_c : Unix.sockaddr -> C.Types.Sockaddr.t
  val c_to_ocaml : C.Types.Sockaddr.union -> int -> Unix.sockaddr
end

(* TODO Move everything that depends on Unix here? Alias the sockaddr stuff so
   we can detach from it quickly. *)
(* TODO Move away from Unix.sockaddr completely? *)
