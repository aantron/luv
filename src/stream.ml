type 'kind stream = 'kind C.Types.Stream.stream
type 'kind t = 'kind stream Handle.t

let coerce :
    type any_type_of_stream any_other_type_of_stream.
    any_type_of_stream t -> any_other_type_of_stream t =
  Obj.magic

module Stream =
struct
  type nonrec 'kind t = 'kind t
end

module Connect_request =
struct
  type t = [ `Connect ] Request.t

  let make () =
    Request.allocate C.Types.Stream.Connect_request.t

  let get_handle request =
    Ctypes.getf
      (Ctypes.(!@) (Request.c request)) C.Types.Stream.Connect_request.handle
    |> Handle.from_c
end

module Shutdown_request =
struct
  type t = [ `Shutdown ] Request.t

  let make () =
    Request.allocate C.Types.Stream.Shutdown_request.t
end

module Write_request =
struct
  type t = [ `Write ] Request.t

  let make () =
    Request.allocate C.Types.Stream.Write_request.t
end

let shutdown_trampoline =
  C.Functions.Stream.Shutdown_request.get_trampoline ()

(* TODO Test *)
let shutdown ~callback ?(request = Shutdown_request.make ()) stream =
  Request.set_callback_2 request callback;
  C.Functions.Stream.shutdown
    (Request.c request) (Handle.c (coerce stream)) shutdown_trampoline

let connection_trampoline =
  C.Functions.Stream.get_connection_trampoline ()

(* TODO Test multiple listen. *)
(* TODO Anything special about the callback lifetime? Think not. *)
let listen ~callback ~backlog server =
  Handle.set_callback
    ~index:C.Types.Stream.connection_callback_index server callback;
  C.Functions.Stream.listen
    (Handle.c (coerce server))
    backlog
    connection_trampoline

(* TODO Explain that these are here because of accept. *)
let init_tcp ?loop () =
  let tcp =
    Handle.allocate
      ~callback_count:C.Types.Stream.callback_count C.Types.TCP.t
  in
  C.Functions.TCP.init (Loop.or_default loop) (Handle.c tcp)
  |> Error.to_result tcp

(* TODO All these coercions... *)
let accept
    : type stream_kind. stream_kind t -> (stream_kind t, _) Result.result =
    fun server ->

  let loop = Handle.get_loop server in
  (* TODO Need server type and an up-cast. *)
  match init_tcp ~loop () with
  | Error error_code ->
    Error error_code
  | Ok client ->
    let error_code =
      C.Functions.Stream.accept
        (Handle.c (coerce server)) (Handle.c (coerce client))
    in
    (* TODO Use helper in Error. *)
    if error_code = Error.success then
      Ok (coerce client)
    else
      Error error_code

(* TODO Move elsewhere? *)
(* TODO Turn into trampoline *)
(* TODO Store references to allocated buffers. *)
let alloc_trampoline =
  C.Functions.Handle.get_alloc_trampoline ()

let read_trampoline =
  C.Functions.Stream.get_read_trampoline ()

(* TODO Test together with write. *)
(* TODO Callback lifetime? *)
(* TODO Reorder all arguments so that callbacks are suggestively last. *)
let read_start ~callback ~allocate stream =
  (* TODO Release the buffer ref and test that. *)
  let callback stream (nread_or_error : Error.t) =
    let result =
      if (nread_or_error :> int) > 0 then begin
        let nread = (nread_or_error :> int) in
        let buffer : Bigstring.t =
          Handle.get_callback
            ~index:C.Types.Stream.buffer_reference_index stream
        in
        Ok (buffer, nread)
      end
      else
        Error nread_or_error
    in
    callback stream result
  in

  Handle.set_callback ~index:C.Types.Stream.read_callback_index stream callback;

  (* TODO Retain reference to the buffer. Test for premature GC of it. *)
  let allocate stream suggested_size =
    let buffer = allocate stream suggested_size in
    Handle.set_callback
      ~index:C.Types.Stream.buffer_reference_index stream buffer;
    buffer
  in

  Handle.set_callback
    ~index:C.Types.Stream.allocate_callback_index stream allocate;

  C.Functions.Stream.read_start
    (Handle.c (coerce stream)) alloc_trampoline read_trampoline

let read_stop stream =
  C.Functions.Stream.read_stop (Handle.c (coerce stream))

let write_trampoline =
  C.Functions.Stream.Write_request.get_trampoline ()

(* TODO Implement in terms of write2 somehow, or a shared underlying
   implementation? Or factor out the initial code? *)
let write ~callback ?(request = Write_request.make ()) stream buffers =
  let count = List.length buffers in
  let iovecs = C.Functions.Buf.bigstrings_to_iovecs buffers count in

  (* TODO The bigstrings must be retained. Test this. *)

  Request.set_callback_2 request (fun request result ->
    C.Functions.Buf.free (Ctypes.to_voidp iovecs);
    callback request result);

  C.Functions.Stream.write
    (Request.c request)
    (Handle.c (coerce stream))
    iovecs
    (Unsigned.UInt.of_int count)
    write_trampoline

let write2
    ~callback ?(request = Write_request.make ()) ~send_handle stream buffers =

  let count = List.length buffers in
  let iovecs = C.Functions.Buf.bigstrings_to_iovecs buffers count in

  (* TODO The bigstrings must be retained. Test this. *)

  Request.set_callback_2 request (fun request result ->
    C.Functions.Buf.free (Ctypes.to_voidp iovecs);
    callback request result);

  C.Functions.Stream.write2
    (Request.c request)
    (Handle.c (coerce stream))
    iovecs
    (Unsigned.UInt.of_int count)
    (Handle.c (coerce send_handle))
    write_trampoline

let try_write stream buffers =
  let count = List.length buffers in
  let iovecs = C.Functions.Buf.bigstrings_to_iovecs buffers count in

  let result =
    C.Functions.Stream.try_write
      (Handle.c (coerce stream))
      iovecs
      (Unsigned.UInt.of_int count)
  in

  C.Functions.Buf.free (Ctypes.to_voidp iovecs);

  result

let is_readable stream =
  C.Functions.Stream.is_readable (Handle.c (coerce stream))

let is_writable stream =
  C.Functions.Stream.is_writable (Handle.c (coerce stream))

let set_blocking stream blocking =
  C.Functions.Stream.set_blocking (Handle.c (coerce stream)) blocking

let get_write_queue_size stream =
  C.Functions.Stream.get_write_queue_size (Handle.c (coerce stream))
  |> Unsigned.Size_t.to_int

(* TODO Round-trip test for this? *)
module Sockaddr =
struct
  let ocaml_to_c address =
    let c_sockaddr = Ctypes.make C.Types.Sockaddr.union in
    let c_sockaddr_length = Ctypes.(allocate int) 0 in
    C.Functions.Sockaddr.ocaml_to_c
      address (Ctypes.addr c_sockaddr) c_sockaddr_length;
    let c_sockaddr = Ctypes.getf c_sockaddr C.Types.Sockaddr.s_gen in
    c_sockaddr
end

module Trampolines =
struct
  let connect =
    C.Functions.Stream.Connect_request.get_trampoline ()
end
