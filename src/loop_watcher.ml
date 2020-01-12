(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module type KIND =
sig
  type kind
  val t : kind C.Types.Handle.t Ctypes.typ
  val init : Loop.t -> kind C.Types.Handle.t Ctypes.ptr -> int
  val get_trampoline :
    unit ->
      (kind C.Types.Handle.t Ctypes.ptr -> unit) Ctypes.static_funptr
  val start :
    kind C.Types.Handle.t Ctypes.ptr ->
    (kind C.Types.Handle.t Ctypes.ptr -> unit) Ctypes.static_funptr ->
      int
  val stop : kind C.Types.Handle.t Ctypes.ptr -> int
end

module Watcher (Kind : KIND) =
struct
  type t = Kind.kind Handle.t

  let init ?loop () =
    let handle = Handle.allocate Kind.t in
    Kind.init (Loop.or_default loop) handle
    |> Error.to_result handle

  let trampoline =
    Kind.get_trampoline ()

  let start handle callback =
    (* If [Handle.is_active handle], then [uv_*_start] will not overwrite the
       handle's callback. We need to emulate this behavior in the wrapper. *)
    if Handle.is_active handle then
      Result.Ok ()
    else begin
      Handle.set_reference handle (Error.catch_exceptions callback);
      Kind.start handle trampoline
      |> Error.to_result ()
    end

  let stop handle =
    Kind.stop handle
    |> Error.to_result ()
end
