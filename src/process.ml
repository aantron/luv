(* https://github.com/ocamllabs/ocaml-ctypes/issues/159 *)

type t = [ `Process ] Handle.t

(* let spawn ?loop:_ () =
  assert false *)
