(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `Process ] Handle.t

type redirection

val to_new_pipe :
  ?readable_in_child:bool ->
  ?writable_in_child:bool ->
  ?overlapped:bool ->
  fd:int ->
  to_parent_pipe:Pipe.t ->
  unit ->
    redirection

val inherit_fd :
  fd:int ->
  from_parent_fd:int ->
    redirection

val inherit_stream :
  fd:int ->
  from_parent_stream:_ Stream.t ->
    redirection

val stdin : int
val stdout : int
val stderr : int

val spawn :
  ?loop:Loop.t ->
  ?on_exit:(t -> exit_status:int -> term_signal:int -> unit) ->
  ?environment:(string * string) list ->
  ?working_directory:string ->
  ?redirect:redirection list ->
  ?uid:int ->
  ?gid:int ->
  ?windows_verbatim_arguments:bool ->
  ?detached:bool ->
  ?windows_hide:bool ->
  ?windows_hide_console:bool ->
  ?windows_hide_gui:bool ->
  string ->
  string list ->
    (t, Error.t) Result.result

val disable_stdio_inheritance : unit -> unit
val kill : t -> int -> (unit, Error.t) Result.result
val kill_pid : pid:int -> int -> (unit, Error.t) Result.result
val pid : t -> int
