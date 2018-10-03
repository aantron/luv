include C.Types.Error
include C.Functions.Error

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
