(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



include C.Types.Error
include C.Functions.Error

let err_name error_code =
  let length = 256 in
  let buffer = Bytes.create length in
  C.Functions.Error.err_name_r
    error_code (Ctypes.ocaml_bytes_start buffer) length;
  let length = Bytes.index buffer '\000' in
  Bytes.sub_string buffer 0 length

let exception_handler =
  ref begin fun exn ->
    prerr_endline (Printexc.to_string exn);
    Printexc.print_backtrace stderr;
    exit 2
  end

let on_unhandled_exception f =
  exception_handler := f

let unhandled_exception exn =
  !exception_handler exn

let catch_exceptions f v =
  try
    f v
  with exn ->
    unhandled_exception exn

let to_result success_value error_code =
  if error_code >= success then
    Result.Ok success_value
  else
    Result.Error error_code

let to_result_lazy get_success_value error_code =
  if error_code >= success then
    Result.Ok (get_success_value ())
  else
    Result.Error error_code

let clamp (code : t) =
  if code >= success then
    success
  else
    code

let coerce : int -> t =
  Obj.magic
