type 'kind stream = 'kind C.Types.Stream.stream
type 'kind t = 'kind stream Handle.t

module Stream :
sig
  type nonrec 'kind t = 'kind t
end

(* TODO Hide these completely? *)
module Connect_request :
sig
  type t = [ `Connect ] Request.t

  val make : unit -> t
  val get_handle : t -> [ `Base ] Stream.t
end

module Shutdown_request :
sig
  type t = [ `Shutdown ] Request.t

  val make : unit -> t
end

module Write_request :
sig
  type t = [ `Write ] Request.t

  val make : unit -> t
  (* TODO get_handle? *)
end

(* TODO Shutdown *)
val shutdown :
  callback:(Shutdown_request.t -> Error.t -> unit) ->
  ?request:Shutdown_request.t ->
  'kind t ->
    Error.t

(* TODO Label the argument? *)
(* TODO Make backlog optional? *)
val listen :
  callback:('kind t -> Error.t -> unit) -> backlog:int -> 'kind t -> Error.t
val accept : 'kind t -> ('kind t, Error.t) Result.result
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
  callback:('kind t -> (Bigstring.t * int, Error.t) Result.result -> unit) ->
  allocate:('kind t -> int -> Bigstring.t) ->
  'kind t ->
    Error.t
val read_stop : 'kind t -> Error.t
val write :
  callback:(Write_request.t -> Error.t -> unit) ->
  ?request:Write_request.t ->
  'kind t ->
  Bigstring.t list ->
    Error.t
(* TODO Allow offsets and lengths into the bigstrings. *)
(* TODO So that should be some kind of iovec type. *)

(* For write2, send_handle must be retained. Does it have to have the same type
   as the handle being used to send it? I guess it doesn't have to be retained,
   because it won't be closed yet. *)
val write2 :
  callback:(Write_request.t -> Error.t -> unit) ->
  ?request:Write_request.t ->
  send_handle:'other_type t ->
  'kind t ->
  Bigstring.t list ->
    Error.t
(* TODO Test *)

val try_write : 'kind t -> Bigstring.t list -> Error.t
val is_readable : 'kind t -> bool
val is_writable : 'kind t -> bool
val set_blocking : 'kind t -> bool -> Error.t
val get_write_queue_size : 'kind t -> int

(**/**)

val init_tcp : ?loop:Loop.t -> unit -> ([ `TCP ] t, Error.t) result

module Sockaddr :
sig
  val ocaml_to_c : Unix.sockaddr -> C.Types.Sockaddr.t
end

module Trampolines :
sig
  val connect :
    (C.Types.Stream.Connect_request.t Ctypes.ptr -> Error.t -> unit)
      Ctypes.static_funptr
end
