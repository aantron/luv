type t = [ `Pipe ] Stream.t

module Mode =
struct
  include C.Types.Pipe.Mode
  type t = int
  let (lor) = (lor)
end

let init ?loop ?(for_handle_passing = false) () =
  let pipe =
    Handle.allocate
      ~callback_count:C.Types.Stream.callback_count C.Types.Pipe.t
  in
  C.Functions.Pipe.init
    (Loop.or_default loop) (Handle.c pipe) for_handle_passing
  |> Error.to_result pipe

(* TODO Get rid of this Obj.magic once uv_file is properly defined as an
   abstract view of int, or whatever it is. *)
let open_ pipe file =
  C.Functions.Pipe.open_ (Handle.c pipe) ((Obj.magic : File.t -> int) file)

let bind pipe name_or_path =
  C.Functions.Pipe.bind (Handle.c pipe) (Ctypes.ocaml_string_start name_or_path)

(* TODO Carefully review lifetimes, combine with TCP review. Test everything. *)
(* TODO What happens with synchronous failure? *)
(* TODO Test *)
(* TODO Test for memory leaks. *)
let connect pipe name_or_path callback =
  let request = Stream.Connect_request.make () in
  Request.set_callback_2 request (fun _request -> callback);
  C.Functions.Pipe.connect
    (Request.c request)
    (Handle.c pipe)
    (Ctypes.ocaml_string_start name_or_path)
    Stream.Connect_request.trampoline

(* TODO grep for all instances of Error not prefdgsdfgfixed with Result. *)

let rec generic_getname ?(buffer_size = 128) c_function pipe =
  let length_cell =
    Ctypes.(allocate size_t) (Unsigned.Size_t.of_int buffer_size) in
  let buffer = Bytes.create buffer_size in
  let result =
    c_function (Handle.c pipe) (Ctypes.ocaml_bytes_start buffer) length_cell in
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

let pending_instances _pipe _count =
  assert false

let pending_count _pipe =
  assert false

let pending_type _pipe =
  assert false

let chmod pipe mode =
  C.Functions.Pipe.chmod (Handle.c pipe) mode

(* TODO Tests. *)
