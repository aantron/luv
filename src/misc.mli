module Domain :
sig
  type t = private int
  val unspec : t
  val inet : t
  val inet6 : t
end

(**/**)

module Buf :
sig
  val bigstrings_to_iovecs : Bigstring.t list -> int -> C.Types.Buf.t Ctypes.ptr
end

module Sockaddr :
sig
  val ocaml_to_c : Unix.sockaddr -> C.Types.Sockaddr.t
  val c_to_ocaml : C.Types.Sockaddr.union -> int -> Unix.sockaddr
end

(* TODO Move everything that depends on Unix here? Alias the sockaddr stuff so
   we can detach from it quickly. *)
(* TODO Os_fd casts. *)
(* TODO Move away from Unix.sockaddr completely? *)
