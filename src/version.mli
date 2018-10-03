
val major : int
val minor : int
val patch : int
val is_release : bool
(* TODO Figure out how to get suffix, probably needs to be bound internally
   as a char pointer, then we can turn it into a lazy value and use Ctypes? *)
(* val suffix : string *)
val hex : int

val version : unit -> int
val string : unit -> string
