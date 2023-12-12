(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = C.Types.Thread.t Ctypes.ptr

let self () =
  Ctypes.addr (C.Functions.Thread.self ())

let equal =
  C.Functions.Thread.equal

let thread_trampoline =
  C.Functions.Thread.get_trampoline ()

let make_thread_options stack_size =
  let module O = C.Types.Thread.Options in
  let options = Ctypes.make O.t in
  begin match stack_size with
  | None ->
    Ctypes.setf options O.flags O.no_flags
  | Some n ->
    Ctypes.setf options O.flags O.has_stack_size;
    Ctypes.setf options O.stack_size (Unsigned.Size_t.of_int n)
  end;
  Ctypes.addr options

let create ?stack_size f =
  let thread = Ctypes.addr (Ctypes.make C.Types.Thread.t) in
  let f = Error.catch_exceptions f in
  let f_gc_root = Ctypes.Root.create f in
  let result =
    C.Functions.Thread.create
      thread
      (make_thread_options stack_size)
      thread_trampoline
      f_gc_root
  in
  if result < 0 then begin
    Ctypes.Root.release f_gc_root;
    Error.result_from_c result
  end
  else
    Ok thread

let create_c ?stack_size ?(argument = Nativeint.zero) f =
  let thread = Ctypes.addr (Ctypes.make C.Types.Thread.t) in
  C.Functions.Thread.create_c thread (make_thread_options stack_size) f argument
  |> Error.to_result thread

let join thread =
  C.Blocking.Thread.join thread
  |> Error.to_result ()

let c mask =
  mask
  |> Bytes.unsafe_to_string
  |> Ctypes.CArray.of_string
  |> Ctypes.CArray.start

let setaffinity thread cpu_mask =
  let mask_size = Bytes.length cpu_mask in
  let old_mask = Bytes.create mask_size in
  let mask_size = Unsigned.Size_t.of_int mask_size in
  C.Functions.Thread.setaffinity thread (c cpu_mask) (c old_mask) mask_size
  |> Error.to_result old_mask

let getaffinity thread =
  match System_info.cpumask_size () with
  | Error _ as error ->
    error
  | Ok mask_size ->
    let cpu_mask = Bytes.create mask_size in
    let mask_size = Unsigned.Size_t.of_int mask_size in
    C.Functions.Thread.getaffinity thread (c cpu_mask) mask_size
    |> Error.to_result cpu_mask
