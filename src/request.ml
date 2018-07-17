(* open Imports *)

(* include Luv_FFI.C.Types.Request *)
(* include Luv_FFI.C.Functions.Request *)

(* type base_request = Luv_FFI.C.Types.Request.base_request *)
(* type 'type_ t = 'type_ Luv_FFI.C.Types.Request.t ptr *)
type 'type_ c_request = 'type_ Luv_FFI.C.Types.Request.t

let coerce :
    type any_type_of_request.
    any_type_of_request c_request Ctypes.ptr ->
      Luv_FFI.C.Types.Request.base_request c_request Ctypes.ptr =
  Obj.magic

type 'type_ t = {
  mutable callback : 'type_ t -> Error.Code.t -> unit;
  mutable finished : bool;
  c_request : 'type_ c_request Ctypes.ptr;
}

exception Request_object_reused_this_is_a_programming_error

let cancel request =
  if request.finished then
    raise Request_object_reused_this_is_a_programming_error;
  Luv_FFI.C.Functions.Request.cancel (coerce request.c_request)

let allocate t =
  let c_request = Ctypes.addr (Ctypes.make t) in
  let request = {callback = (fun _ _ -> ()); finished = false; c_request} in
  let gc_root = Ctypes.Root.create request in
  Luv_FFI.C.Functions.Request.set_data (coerce c_request) gc_root;
  request

let c request =
  request.c_request

let set_callback request callback =
  if request.finished then
    raise Request_object_reused_this_is_a_programming_error;
  request.callback <- callback

let finished request =
  Luv_FFI.C.Functions.Request.get_data (coerce request.c_request)
  |> Ctypes.Root.release;
  request.finished <- true


(* let get_data request =
  get_data (coerce request)

let set_data request data =
  set_data (coerce request) data

let get_type request =
  get_type (coerce request) *)
