type t = [ `Process ] Handle.t

(* TODO Need to implement pipe and tty handles first before working on
   process. This is needed for the stdio inheritance options. *)

(* TODO All the args. *)
(* TODO Types of setuid and setgid... *)
(* val spawn :
  ?loop:Loop.t ->
  ?on_exit:(t -> int64 -> int -> unit) ->
  ?environment:string list ->
  ?setuid:int ->
  ?setgid:int ->
  ?windows_verbatim_arguments:bool ->
  ?detached:bool ->
  ?windows_hide:bool ->
  string ->
  string list ->
    (t, Error.t) Result.result *)
