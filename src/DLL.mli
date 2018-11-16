type t

val open_ : string -> t option
val close : t -> unit
val sym : t -> string -> nativeint option
val last_error : t -> string

(* TODO Create an example for this. *)
