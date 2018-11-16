module type WITH_DATA_FIELD =
sig
  type 'kind base
  type 'kind t = ('kind base) Ctypes.structure
  val set_data : ([ `Base ] t) Ctypes.ptr -> unit Ctypes.ptr -> unit
  val get_data : ([ `Base ] t) Ctypes.ptr -> unit Ctypes.ptr
  val default_reference_count : int
end

module Retained (Object : WITH_DATA_FIELD) =
struct
  type 'kind t = ('kind Object.t) Ctypes.ptr

  let coerce : _ t -> [ `Base ] t =
    Obj.magic

  (* DOC Explain the handle/request retention scheme. *)
  let allocate ?(reference_count = Object.default_reference_count) kind =
    let references = Array.make reference_count ignore in

    let c_object = Ctypes.addr (Ctypes.make kind) in
    references.(C.Types.Handle.self_reference_index) <- Obj.magic c_object;

    let gc_root = Ctypes.Root.create references in
    Object.set_data (coerce c_object) gc_root;

    c_object

  let release c_object =
    Ctypes.Root.release (Object.get_data (coerce c_object))

  let set_reference
      ?(index = C.Types.Handle.generic_callback_index) c_object value =

    let references : _ array =
      Ctypes.Root.get (Object.get_data (coerce c_object)) in
    references.(index) <- Obj.magic value
end

module Buf =
struct
  let bigstrings_to_iovecs bigstrings count =
    let iovecs = Ctypes.CArray.make C.Types.Buf.t count in
    bigstrings |> List.iteri begin fun index bigstring ->
      let iovec = Ctypes.CArray.get iovecs index in
      let base = Ctypes.(bigarray_start array1) bigstring in
      let length = Bigarray.Array1.dim bigstring in
      Ctypes.setf iovec C.Types.Buf.base base;
      Ctypes.setf iovec C.Types.Buf.len (Unsigned.UInt.of_int length)
    end;
    iovecs
end

module Bit_flag =
struct
  type t = int
  let (lor) = (lor)
  let list flags = List.fold_left (lor) 0 flags
  let test flags flag = (flags land flag) <> 0
end
