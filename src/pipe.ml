type t = [ `Pipe ] Stream.t

module Mode =
struct
  include C.Types.Pipe.Mode
  type t = int
  let (lor) = (lor)
end

let init ?loop ?(for_handle_passing = false) () =
  let pipe = Stream.allocate C.Types.Pipe.t in
  C.Functions.Pipe.init (Loop.or_default loop) pipe for_handle_passing
  |> Error.to_result pipe

let open_ pipe file =
  C.Functions.Pipe.open_ pipe (File.to_int file)

let bind =
  C.Blocking.Pipe.bind

let connect pipe name_or_path callback =
  let request = Stream.Connect_request.make () in
  Request.set_callback_2 request (fun _request -> callback);
  C.Functions.Pipe.connect
    request
    pipe
    (Ctypes.ocaml_string_start name_or_path)
    Stream.Connect_request.trampoline

let rec generic_getname ?(buffer_size = 128) c_function pipe =
  let length_cell =
    Ctypes.(allocate size_t) (Unsigned.Size_t.of_int buffer_size) in
  let buffer = Bytes.create buffer_size in
  let result = c_function pipe (Ctypes.ocaml_bytes_start buffer) length_cell in
  let final_length = Unsigned.Size_t.to_int (Ctypes.(!@) length_cell) in
  if result >= Error.success then
    Result.Ok (Bytes.sub_string buffer 0 final_length)
  else
    if result = Error.enobufs then
      generic_getname ~buffer_size:final_length c_function pipe
    else
      Result.Error result

let getsockname = generic_getname C.Functions.Pipe.getsockname
let getpeername = generic_getname C.Functions.Pipe.getpeername

let pending_instances =
  C.Functions.Pipe.pending_instances

let accept_handle pipe handle =
  C.Functions.Stream.accept (Stream.coerce pipe) (Stream.coerce handle)

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

let chmod =
  C.Functions.Pipe.chmod
