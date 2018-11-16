type t = [ `FS_poll ] Handle.t

val init : ?loop:Loop.t -> unit -> (t, Error.t) Result.result
val start :
  ?interval:int ->
  t ->
  string ->
  ((File.Stat.t * File.Stat.t, Error.t) Result.result -> unit) ->
    unit
val stop : t -> Error.t
