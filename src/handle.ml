(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



include Helpers.Retained
  (struct
    include C.Types.Handle
    type 'kind base = 'kind handle
    include C.Functions.Handle
  end)

let is_closing handle =
  C.Functions.Handle.is_closing (coerce handle)

let close_trampoline =
  C.Functions.Handle.get_close_trampoline ()

let close handle callback =
  if is_closing handle then
    ()
  else begin
    set_reference
      ~index:C.Types.Handle.close_callback_index
      handle
      (fun () ->
        release handle;
        callback ());
    C.Functions.Handle.close (coerce handle) close_trampoline
  end

let is_active handle =
  C.Functions.Handle.is_active (coerce handle)

let ref handle =
  C.Functions.Handle.ref (coerce handle)

let unref handle =
  C.Functions.Handle.unref (coerce handle)

let has_ref handle =
  C.Functions.Handle.has_ref (coerce handle)

let buffer_size c_function handle =
  let size = Ctypes.(allocate int 0) in
  c_function (coerce handle) size
  |> Error.to_result (Ctypes.(!@) size)

let send_buffer_size handle =
  buffer_size C.Functions.Handle.send_buffer_size handle
let recv_buffer_size handle =
  buffer_size C.Functions.Handle.recv_buffer_size handle

let set_buffer_size c_function handle size =
  let size = Ctypes.(allocate int size) in
  c_function (coerce handle) size

let set_send_buffer_size handle size =
  set_buffer_size C.Functions.Handle.send_buffer_size handle size
let set_recv_buffer_size handle size =
  set_buffer_size C.Functions.Handle.recv_buffer_size handle size

let fileno handle =
  let os_fd = Ctypes.make C.Types.Os_fd.t in
  C.Functions.Handle.fileno (coerce handle) (Ctypes.addr os_fd)
  |> Error.to_result os_fd

let get_loop handle =
  C.Functions.Handle.get_loop (coerce handle)
