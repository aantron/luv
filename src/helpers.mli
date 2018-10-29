(* A few functions that are shared between modules, but should not be exposed
   for the user to call. *)

module type WITH_DATA_FIELD =
sig
  type 'kind base
  type 'kind t = ('kind base) Ctypes.structure
  val set_data : ([ `Base ] t) Ctypes.ptr -> unit Ctypes.ptr -> unit
  val get_data : ([ `Base ] t) Ctypes.ptr -> unit Ctypes.ptr
end

module Retained (Object : WITH_DATA_FIELD) :
sig
  type 'kind t = ('kind Object.t) Ctypes.ptr

  val allocate : ?reference_count:int -> ('kind Object.t) Ctypes.typ -> 'kind t
  val release : _ t -> unit
  val set_reference : ?index:int -> _ t -> _ -> unit
  val coerce : _ t -> [ `Base ] t
end

module Buf :
sig
  val bigstrings_to_iovecs :
    Bigstring.t list -> int -> C.Types.Buf.t Ctypes.carray
end

module Sockaddr :
sig
  val ocaml_to_c : Misc.Sockaddr.t -> C.Types.Sockaddr.t
  val c_to_ocaml : C.Types.Sockaddr.union -> int -> Misc.Sockaddr.t
end
