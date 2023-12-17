(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `Pipe ] Stream.t

module Mode =
struct
  type t = [
    | `READABLE
    | `WRITABLE
  ]

  let to_c = let open C.Types.Pipe.Mode in function
    | `READABLE -> readable
    | `WRITABLE -> writable
end

let init ?loop ?(for_handle_passing = false) () =
  let pipe = Stream.allocate C.Types.Pipe.t in
  C.Functions.Pipe.init (Loop.or_default loop) pipe for_handle_passing
  |> Error.to_result pipe

let pipe ?(read_flags = [`NONBLOCK]) ?(write_flags = [`NONBLOCK]) () =
  let convert_flags = function
    | [] -> 0
    | _ -> C.Types.Process.Redirection.overlapped_pipe
  in
  let fds = Ctypes.allocate_n C.Types.File.t ~count:2 in
  C.Functions.Pipe.pipe
    fds
    (convert_flags read_flags)
    (convert_flags write_flags)
  |> Error.to_result_f Ctypes.(fun () ->
    File.from_int (!@ fds), File.from_int (!@ (fds +@ 1)))

let open_ pipe file =
  C.Functions.Pipe.open_ pipe (File.to_int file)
  |> Error.to_result ()

let bind ?(no_truncate = false) pipe name =
  let use_bind2 =
    match name.[0] with
    | '\x00' -> true
    | _ | exception Invalid_argument _ -> no_truncate
  in
  begin if use_bind2 then
    let length = String.length name |> Unsigned.Size_t.of_int in
    let no_truncate = if no_truncate then C.Types.Pipe.no_truncate else 0 in
    C.Blocking.Pipe.bind2 pipe name length no_truncate
  else
    C.Blocking.Pipe.bind pipe name
  end
  |> Error.to_result ()

let connect ?(no_truncate = false) pipe name_or_path callback =
  let request = Stream.Connect_request.make () in
  let callback result =
    Error.catch_exceptions callback (Error.to_result () result)
  in
  Request.set_callback request callback;
  let use_connect2 =
    match name_or_path.[0] with
    | '\x00' -> true
    | _ | exception Invalid_argument _ -> no_truncate
  in
  let c_name_or_path = Ctypes.ocaml_string_start name_or_path in
  if use_connect2 then
    let length = String.length name_or_path |> Unsigned.Size_t.of_int in
    let no_truncate = if no_truncate then C.Types.Pipe.no_truncate else 0 in
    C.Functions.Pipe.connect2
      request
      pipe
      c_name_or_path
      length
      no_truncate
      Stream.Connect_request.trampoline
  else
    C.Functions.Pipe.connect
      request
      pipe
      c_name_or_path
      Stream.Connect_request.trampoline

let rec generic_getname ?(buffer_size = 128) c_function pipe =
  let length_cell =
    Ctypes.(allocate size_t) (Unsigned.Size_t.of_int buffer_size) in
  let buffer = Bytes.create buffer_size in
  let result = c_function pipe (Ctypes.ocaml_bytes_start buffer) length_cell in
  let final_length = Unsigned.Size_t.to_int (Ctypes.(!@) length_cell) in
  if result >= 0 then
    Ok (Bytes.sub_string buffer 0 final_length)
  else
    if result = C.Types.Error.enobufs then
      generic_getname ~buffer_size:final_length c_function pipe
    else
      Error.result_from_c result

let getsockname =
  generic_getname C.Functions.Pipe.getsockname

let getpeername =
  generic_getname C.Functions.Pipe.getpeername

let pending_instances =
  C.Functions.Pipe.pending_instances

let accept_handle pipe handle =
  C.Functions.Stream.accept (Stream.coerce pipe) (Stream.coerce handle)
  |> Error.to_result ()

let receive_handle pipe =
  let pending_count = C.Functions.Pipe.pending_count pipe in
  if pending_count = 0 then
    `None
  else
    let pending_type = C.Functions.Pipe.pending_type pipe in
    if pending_type = C.Types.Handle.Type.tcp then
      `TCP (accept_handle pipe)
    else if pending_type = C.Types.Handle.Type.named_pipe then
      `Pipe (accept_handle pipe)
    else
      `None

let chmod pipe mode =
  let mode = Helpers.Bit_field.list_to_c Mode.to_c mode in
  C.Functions.Pipe.chmod pipe mode
  |> Error.to_result ()
