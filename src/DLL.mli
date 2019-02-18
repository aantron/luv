(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t

val open_ : string -> t option
val close : t -> unit
val sym : t -> string -> nativeint option
val last_error : t -> string

(* TODO Create an example for this. *)
