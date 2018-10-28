type t = [ `Process ] Handle.t

type redirection

(* DOC This is different from Pipe.Mode.t... minor libuv design flaw. *)
module Pipe_mode :
sig
  type t

  val readable : t
  val writable : t

  val (lor) : t -> t -> t
end

val to_new_pipe :
  ?mode_in_child:Pipe_mode.t ->
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
  string ->
  string list ->
    (t, Error.t) Result.result

val disable_stdio_inheritance : unit -> unit
val kill : t -> int -> Error.t
val kill_pid : pid:int -> int -> Error.t
val pid : t -> int
