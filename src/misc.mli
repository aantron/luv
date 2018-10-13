module Domain :
sig
  type t = private int
  val unspec : t
  val inet : t
  val inet6 : t
end

(**/**)

module Sockaddr :
sig
  val ocaml_to_c : Unix.sockaddr -> C.Types.Sockaddr.t
end
