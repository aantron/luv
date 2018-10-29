module type WITH_DATA_FIELD =
sig
  type 'kind base
  type 'kind t = ('kind base) Ctypes.structure
  val set_data : ([ `Base ] t) Ctypes.ptr -> unit Ctypes.ptr -> unit
  val get_data : ([ `Base ] t) Ctypes.ptr -> unit Ctypes.ptr
end

module Retained (Object : WITH_DATA_FIELD) =
struct
  type 'kind t = ('kind Object.t) Ctypes.ptr

  let coerce : _ t -> [ `Base ] t =
    Obj.magic

  (* DOC Explain the handle/request retention scheme. *)
  let allocate
      ?(reference_count = C.Types.Handle.minimum_reference_count) kind =

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

module Sockaddr =
struct
  external get_sockaddr : Unix.sockaddr -> nativeint -> int =
    "luv_get_sockaddr"

  let ocaml_to_c address =
    let c_sockaddr = Ctypes.make C.Types.Sockaddr.union in
    let c_storage = Ctypes.(raw_address_of_ptr (to_voidp (addr c_sockaddr))) in
    ignore (get_sockaddr (Misc.Sockaddr.to_unix address) c_storage);
    let c_sockaddr = Ctypes.getf c_sockaddr C.Types.Sockaddr.s_gen in
    c_sockaddr

  external alloc_sockaddr : nativeint -> int -> Unix.sockaddr =
    "luv_alloc_sockaddr"

  let c_to_ocaml address length =
    let c_storage = Ctypes.(raw_address_of_ptr (to_voidp (addr address))) in
    Misc.Sockaddr.from_unix (alloc_sockaddr c_storage length)
end
