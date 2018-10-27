type 'kind t = 'kind C.Types.Stream.stream Handle.t

let coerce : type kind. kind t -> [ `Base ] t =
  Obj.magic

let shutdown_trampoline =
  C.Functions.Stream.Shutdown_request.get_trampoline ()

let shutdown stream callback =
  let request = Request.allocate C.Types.Stream.Shutdown_request.t in
  Request.set_callback_2 request (fun _request -> callback);
  let immediate_result =
    C.Functions.Stream.shutdown
      (Request.c request) (Handle.c (coerce stream)) shutdown_trampoline
  in
  if immediate_result < Error.success then begin
    Request.clear_callback request;
    callback immediate_result
  end

let connection_trampoline =
  C.Functions.Stream.get_connection_trampoline ()

(* DOC Argue that the callback is properly memory-managed. *)
let listen ?(backlog = C.Types.Stream.somaxconn) server callback =
  Handle.set_callback
    ~index:C.Types.Stream.connection_callback_index
    server
    (fun _server -> callback);
  let immediate_result =
    C.Functions.Stream.listen
      (Handle.c (coerce server))
      backlog
      connection_trampoline
  in
  if immediate_result < Error.success then
    callback immediate_result

let accept ~server ~client =
  C.Functions.Stream.accept
    (Handle.c (coerce server)) (Handle.c (coerce client))

let alloc_trampoline =
  C.Functions.Handle.get_alloc_trampoline ()

let read_trampoline =
  C.Functions.Stream.get_read_trampoline ()

(* DOC Document memory management of this function. *)
let read_start ?(allocate = Bigstring.create) stream callback =
  let last_allocated_buffer = ref None in

  Handle.set_callback stream ~index:C.Types.Stream.read_callback_index
      begin fun _stream (nread_or_error : Error.t) ->

    let result =
      if (nread_or_error :> int) > 0 then begin
        let nread = (nread_or_error :> int) in
        let buffer =
          match !last_allocated_buffer with
          | Some buffer -> buffer
          | None -> assert false
        in
        last_allocated_buffer := None;
        Result.Ok (buffer, nread)
      end
      else begin
        last_allocated_buffer := None;
        Result.Error nread_or_error
      end
    in
    callback result
  end;

  Handle.set_callback stream ~index:C.Types.Stream.allocate_callback_index
      begin fun _stream suggested_size ->

    let buffer = allocate suggested_size in
    last_allocated_buffer := Some buffer;
    buffer
  end;

  let immediate_result =
    C.Functions.Stream.read_start
      (Handle.c (coerce stream)) alloc_trampoline read_trampoline
  in
  if immediate_result < Error.success then
    callback (Error immediate_result)

let read_stop stream =
  C.Functions.Stream.read_stop (Handle.c (coerce stream))

let write_trampoline =
  C.Functions.Stream.Write_request.get_trampoline ()

let write stream buffers callback =
  let request = Request.allocate C.Types.Stream.Write_request.t in

  let count = List.length buffers in
  let iovecs = Misc.Buf.bigstrings_to_iovecs buffers count in

  Request.set_callback_2 request (fun _request result ->
    C.Functions.Buf.free (Ctypes.to_voidp iovecs);
    ignore (Sys.opaque_identity buffers);
    callback result);

  let immediate_result =
    C.Functions.Stream.write
      (Request.c request)
      (Handle.c (coerce stream))
      iovecs
      (Unsigned.UInt.of_int count)
      write_trampoline
  in

  if immediate_result < Error.success then begin
    C.Functions.Buf.free (Ctypes.to_voidp iovecs);
    Request.clear_callback request;
    callback immediate_result
  end

(* DOC send_handle must remain open during the operation. *)
let write2 stream buffers ~send_handle callback =
  let request = Request.allocate C.Types.Stream.Write_request.t in

  let count = List.length buffers in
  let iovecs = Misc.Buf.bigstrings_to_iovecs buffers count in

  Request.set_callback_2 request (fun _request result ->
    C.Functions.Buf.free (Ctypes.to_voidp iovecs);
    ignore (Sys.opaque_identity buffers);
    callback result);

  let immediate_result =
    C.Functions.Stream.write2
      (Request.c request)
      (Handle.c (coerce stream))
      iovecs
      (Unsigned.UInt.of_int count)
      (Handle.c (coerce send_handle))
      write_trampoline
  in

  if immediate_result < Error.success then begin
    C.Functions.Buf.free (Ctypes.to_voidp iovecs);
    Request.clear_callback request;
    callback immediate_result
  end

let try_write stream buffers =
  let count = List.length buffers in
  let iovecs = Misc.Buf.bigstrings_to_iovecs buffers count in

  let result =
    C.Functions.Stream.try_write
      (Handle.c (coerce stream))
      iovecs
      (Unsigned.UInt.of_int count)
  in

  C.Functions.Buf.free (Ctypes.to_voidp iovecs);
  ignore (Sys.opaque_identity buffers);

  Error.to_result (result :> int) result

let is_readable stream =
  C.Functions.Stream.is_readable (Handle.c (coerce stream))

let is_writable stream =
  C.Functions.Stream.is_writable (Handle.c (coerce stream))

let set_blocking stream blocking =
  C.Functions.Stream.set_blocking (Handle.c (coerce stream)) blocking

let get_write_queue_size stream =
  C.Functions.Stream.get_write_queue_size (Handle.c (coerce stream))
  |> Unsigned.Size_t.to_int

module Connect_request =
struct
  type t = [ `Connect ] Request.t

  let make () =
    Request.allocate C.Types.Stream.Connect_request.t

  let trampoline =
    C.Functions.Stream.Connect_request.get_trampoline ()
end
