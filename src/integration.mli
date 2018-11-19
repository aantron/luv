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
