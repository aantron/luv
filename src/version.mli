(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



val major : int
val minor : int
val patch : int
val is_release : bool
val suffix : string
val hex : int

val version : unit -> int
val string : unit -> string
