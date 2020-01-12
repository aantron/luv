(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Mode :
sig
  type t = [
    | `NORMAL
    | `RAW
    | `IO
  ]
end

type t = [ `TTY ] Stream.t

val init : ?loop:Loop.t -> File.t -> (t, Error.t) Result.result
val set_mode : t -> Mode.t -> (unit, Error.t) Result.result
val reset_mode : unit -> (unit, Error.t) Result.result
val get_winsize : t -> (int * int, Error.t) Result.result

module Vterm_state :
sig
  type t = [
    | `SUPPORTED
    | `UNSUPPORTED
  ]
end

val set_vterm_state : Vterm_state.t -> unit
val get_vterm_state : unit -> (Vterm_state.t, Error.t) Result.result
