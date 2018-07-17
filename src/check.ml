type check = Luv_FFI.C.Types.Check.check
type t = check Handle.t

let init ?loop () =
  let check = Handle.allocate Luv_FFI.C.Types.Check.t in
  Luv_FFI.C.Functions.Check.init (Loop.or_default loop) (Handle.c check)
  |> Error.to_result check

let trampoline =
  Luv_FFI.C.Functions.Check.get_trampoline ()

let start ~callback check =
  (* If [Handle.is_active check], then [uv_check_start] will not overwrite the
     handle's callback. We need to emulate this behavior in the wrapper. *)
  if Handle.is_active check then
    Error.Code.success
  else begin
    Handle.set_callback check callback;
    Luv_FFI.C.Functions.Check.start (Handle.c check) trampoline
  end

let stop check =
  Luv_FFI.C.Functions.Check.stop (Handle.c check)
