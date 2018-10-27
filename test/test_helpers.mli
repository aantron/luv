val check_success : string -> Luv.Error.t -> unit
val check_error_code : string -> Luv.Error.t -> Luv.Error.t -> unit

val check_success_result : string -> ('a, Luv.Error.t) Result.result -> 'a
val check_error_result :
  string -> Luv.Error.t -> (_, Luv.Error.t) Result.result -> unit

val check_not_null : string -> _ Ctypes.ptr -> unit
val check_pointer : string -> 'a Ctypes.ptr -> 'a Ctypes.ptr -> unit

val check_directory_entries :
  string -> string list -> Luv.File.Dirent.t list -> unit

val check_address : string -> Unix.sockaddr -> Unix.sockaddr -> unit

val make_callback : unit -> (_ -> unit)
val no_memory_leak : ?base_repetitions:int -> (int -> unit) -> unit

val default_loop : Luv.Loop.t
val run : ?with_timeout:bool -> unit -> unit

val port : unit -> int
