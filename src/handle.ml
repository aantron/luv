open Imports

type 'type_ c_handle = 'type_ Luv_FFI.C.Types.Handle.t

let coerce :
    type any_type_of_handle.
    any_type_of_handle c_handle ptr ->
      Luv_FFI.C.Types.Handle.base_handle c_handle ptr =
  Obj.magic

(* TODO Document how the callback table works. Figure it out first? *)
type 'type_ t = {
  mutable callback_table : ('type_ t -> unit) array;
  c_handle : 'type_ c_handle ptr;
}

(* TODO Multiple callbacks need to be stored in each handle somewhere. Also,
   they will have different type signatures. It's probably easiest to just
   select and call them directly from C.

   The indexes can be made into an enum, and discovered from C. *)

exception Handle_already_closed_this_is_a_programming_logic_error

let is_closing handle =
  Luv_FFI.C.Functions.Handle.is_closing (coerce (handle.c_handle))

let raise_if_closed handle =
  if is_closing handle then
    raise Handle_already_closed_this_is_a_programming_logic_error

let allocate ?(callback_count = Luv_FFI.C.Types.Handle.callback_count) t =
  let c_handle = Ctypes.addr (Ctypes.make t) in
  let callback_table = Array.make callback_count ignore in
  let handle = {callback_table; c_handle} in
  let gc_root = Ctypes.Root.create handle in
  Luv_FFI.C.Functions.Handle.set_data (coerce c_handle) gc_root;
  handle

let c handle =
  raise_if_closed handle;
  handle.c_handle

let from_c c_handle =
  coerce c_handle
  |> Luv_FFI.C.Functions.Handle.get_data
  |> Ctypes.Root.get

let set_callback
    ?(index = Luv_FFI.C.Types.Handle.generic_callback_index) handle callback =
  raise_if_closed handle;
  let callback : (_ t -> unit) = Obj.magic callback in
  handle.callback_table.(index) <- callback

let get_callback ~index handle =
  Obj.magic handle.callback_table.(index)

let close_trampoline =
  Luv_FFI.C.Functions.Handle.get_close_trampoline ()

let close handle =
  if is_closing handle then
    ()

  else begin
    let close_callback handle =
      Luv_FFI.C.Functions.Handle.get_data (coerce handle.c_handle)
      |> Ctypes.Root.release
    in
    handle.callback_table.(Luv_FFI.C.Types.Handle.generic_callback_index) <-
      close_callback;
    Luv_FFI.C.Functions.Handle.close (coerce handle.c_handle) close_trampoline
  end

let is_active handle =
  Luv_FFI.C.Functions.Handle.is_active (coerce handle.c_handle)

let ref handle =
  Luv_FFI.C.Functions.Handle.ref (coerce handle.c_handle)

let unref handle =
  Luv_FFI.C.Functions.Handle.unref (coerce handle.c_handle)

let has_ref handle =
  Luv_FFI.C.Functions.Handle.has_ref (coerce handle.c_handle)

let get_loop handle =
  Luv_FFI.C.Functions.Handle.get_loop (coerce handle.c_handle)



(* let send_buffer_size handle size_cell =
  send_buffer_size (coerce_ptr handle) size_cell

let recv_buffer_size handle size_cell =
  recv_buffer_size (coerce_ptr handle) size_cell

let fileno handle fileno_cell =
  fileno (coerce_ptr handle) fileno_cell *)

(* let get_type handle =
  get_type (coerce_ptr handle) *)
