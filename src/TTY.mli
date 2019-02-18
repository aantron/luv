(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Mode :
sig
  type t

  val normal : t
  val raw : t
  val io : t
end

type t = [ `TTY ] Stream.t

val init : ?loop:Loop.t -> File.t -> (t, Error.t) Result.result
val set_mode : t -> Mode.t -> Error.t
val reset_mode : unit -> Error.t
val get_winsize : t -> (int * int, Error.t) Result.result
