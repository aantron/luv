type 'kind c_handle = 'kind C.Types.Handle.t

let coerce :
    type any_type_of_handle.
    any_type_of_handle c_handle Ctypes.ptr -> [ `Base ] c_handle Ctypes.ptr =
  Obj.magic

(* DOC Document how the callback table works. *)
type 'kind t = {
  mutable callback_table : ('kind t -> unit) array;
  c_handle : 'kind c_handle Ctypes.ptr;
}

exception Handle_already_closed_this_is_a_programming_logic_error

let is_closing handle =
  C.Functions.Handle.is_closing (coerce (handle.c_handle))

let raise_if_closed handle =
  if is_closing handle then
    raise Handle_already_closed_this_is_a_programming_logic_error

let allocate ?(callback_count = C.Types.Handle.callback_count) t =
  let c_handle = Ctypes.addr (Ctypes.make t) in
  let callback_table = Array.make callback_count ignore in
  let handle = {callback_table; c_handle} in
  let gc_root = Ctypes.Root.create handle in
  C.Functions.Handle.set_data (coerce c_handle) gc_root;
  handle

let c handle =
  raise_if_closed handle;
  handle.c_handle

let from_c c_handle =
  coerce c_handle
  |> C.Functions.Handle.get_data
  |> Ctypes.Root.get

let set_callback
    ?(index = C.Types.Handle.generic_callback_index) handle callback =
  raise_if_closed handle;
  let callback : (_ t -> unit) = Obj.magic callback in
  handle.callback_table.(index) <- callback

let get_callback ~index handle =
  Obj.magic handle.callback_table.(index)

let close_trampoline =
  C.Functions.Handle.get_close_trampoline ()

let close handle =
  if is_closing handle then
    ()

  else begin
    let close_callback handle =
      C.Functions.Handle.get_data (coerce handle.c_handle)
      |> Ctypes.Root.release
    in
    handle.callback_table.(C.Types.Handle.generic_callback_index) <-
      close_callback;
    C.Functions.Handle.close (coerce handle.c_handle) close_trampoline
  end

let is_active handle =
  C.Functions.Handle.is_active (coerce handle.c_handle)

let ref handle =
  C.Functions.Handle.ref (coerce handle.c_handle)

let unref handle =
  C.Functions.Handle.unref (coerce handle.c_handle)

let has_ref handle =
  C.Functions.Handle.has_ref (coerce handle.c_handle)

let get_loop handle =
  C.Functions.Handle.get_loop (coerce handle.c_handle)
