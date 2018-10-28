include C.Types.Error
include C.Functions.Error

let err_name error_code =
  let length = 256 in
  let buffer = Bytes.create length in
  C.Functions.Error.err_name_r
    error_code (Ctypes.ocaml_bytes_start buffer) length;
  let length = Bytes.index buffer '\000' in
  Bytes.sub_string buffer 0 length

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
