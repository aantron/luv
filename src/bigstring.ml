(* TODO Create an .mli file for this. *)

type t = (char, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t

let create =
  Bigarray.(Array1.create Char C_layout)
