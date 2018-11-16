(* A few functions that are shared between modules, but should not be exposed
   for the user to call. *)

module type WITH_DATA_FIELD =
sig
  type 'kind base
  type 'kind t = ('kind base) Ctypes.structure
  val set_data : ([ `Base ] t) Ctypes.ptr -> unit Ctypes.ptr -> unit
  val get_data : ([ `Base ] t) Ctypes.ptr -> unit Ctypes.ptr
  val default_reference_count : int
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

module Bit_flag :
sig
  type t = int
  val (lor) : t -> t -> t
  val list : t list -> t
  val test : t -> t -> bool
end
