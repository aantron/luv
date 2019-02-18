(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



val register :
  before_io:(unit -> Loop.Run_mode.t) ->
  after_io:(more_io:bool -> [ `Keep_running | `Stop ]) ->
  unit ->
    unit

module Start_and_stop :
sig
  val run : unit -> unit
  val stop : unit -> unit
end
