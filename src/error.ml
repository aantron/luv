(* TODO Figure out how to organize this stuff, so that it is legible in once
   place at a glance. *)
(* TODO Link to the libuv docs, http://docs.libuv.org/en/v1.x/errors.html *)

(* From the original error.mli: *)
(* http://docs.libuv.org/en/v1.x/errors.html *)
(* TODO License headers for all files. *)
(* TODO Can ctypes help to generate this stuff somehow? *)
(* TODO Document what version of libuv we are running with and/or vendor it. *)
(* TODO Compare uwt *)
(* TODO Compare, translate to Unix module errors. *)

(* TODO Notes from the libuv docs about this function sometimes leaking
   memory. *)

module Code = Luv_FFI.C.Types.Error
include Luv_FFI.C.Functions.Error

let to_result success_value error_code =
  if error_code = Code.success then
    Result.Ok success_value
  else
    Result.Error error_code
