(* TODO Rename 'type type parameters. that really sucks. *)
type 'type_ stream = 'type_ Luv_FFI.C.Types.Stream.streams_only
type 'type_ t = 'type_ stream Handle.t
type base_stream

module Stream :
sig
  type nonrec 'type_ t = 'type_ t
end

(* TODO Hide these completely? *)
module Connect_request :
sig
  type connect = Luv_FFI.C.Types.Stream.Connect_request.connect
  type t = connect Request.t

  val make : unit -> t
  val get_handle : t -> base_stream Stream.t
end

module Shutdown_request :
sig
  type shutdown
  type t = shutdown Request.t

  val make : unit -> t
end

module Write_request :
sig
  type write
  type t = write Request.t

  val make : unit -> t
  (* TODO get_handle? *)
end

(* TODO Shutdown *)
val shutdown :
  callback:(Shutdown_request.t -> Error.Code.t -> unit) ->
  ?request:Shutdown_request.t ->
  'type_ t ->
    Error.Code.t

(* TODO Label the argument? *)
(* TODO Make backlog optional? *)
val listen :
  callback:('type_ t -> Error.Code.t -> unit) -> backlog:int -> 'type_ t ->
    Error.Code.t
val accept : 'type_ t -> ('type_ t, Error.Code.t) Result.result
(* TODO Label the argument? *)
(* TODO This forces subclass init functions into this module. *)

(* TODO Expose the allocate strategy? This should probably just be handled by
   the binding internally for now. However, exposing the allocation strategy
   allows for 0-copy pull-reading to be implemented. *)
(* TODO Test cases for explicit allocation.
 *)
(* TODO 80 columns. *)
(* TODO Document how to use allocate and read_stop together for in-place
   reading into a single buffer. *)
val read_start :
  callback:('type_ t -> (Bigstring.t * int, Error.Code.t) Result.result -> unit) ->
  allocate:('type_ t -> int -> Bigstring.t) ->
  'type_ t ->
    Error.Code.t
val read_stop : 'type_ t -> Error.Code.t
val write :
  callback:(Write_request.t -> Error.Code.t -> unit) ->
  ?request:Write_request.t ->
  'type_ t ->
  Bigstring.t list ->
    Error.Code.t
(* TODO Allow offsets and lengths into the bigstrings. *)
(* TODO So that should be some kind of iovec type. *)

(* For write2, send_handle must be retained. Does it have to have the same type
   as the handle being used to send it? I guess it doesn't have to be retained,
   because it won't be closed yet. *)
val write2 :
  callback:(Write_request.t -> Error.Code.t -> unit) ->
  ?request:Write_request.t ->
  send_handle:'other_type t ->
  'type_ t ->
  Bigstring.t list ->
    Error.Code.t
(* TODO Test *)

val try_write : 'type_ t -> Bigstring.t list -> Error.Code.t
val is_readable : 'type_ t -> bool
val is_writable : 'type_ t -> bool
val set_blocking : 'type_ t -> bool -> Error.Code.t
val get_write_queue_size : 'type_ t -> int

(* TODO Internal *)

val init_tcp :
  ?loop:(Loop.t Ctypes.ptr) -> unit ->
    (Luv_FFI.C.Types.TCP.tcp t, Error.Code.t) result

module Sockaddr :
sig
  val ocaml_to_c : Unix.sockaddr -> Luv_FFI.C.Types.Sockaddr.gen
end

module Trampolines :
sig
  val connect :
    (Luv_FFI.C.Types.Stream.Connect_request.t Ctypes.ptr ->
     Error.Code.t ->
      unit)
        Ctypes.static_funptr
end
