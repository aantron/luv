type idle = Luv_FFI.C.Types.Idle.idle
type t = idle Handle.t

let init ?loop () =
  let idle = Handle.allocate Luv_FFI.C.Types.Idle.t in
  Luv_FFI.C.Functions.Idle.init (Loop.or_default loop) (Handle.c idle)
  |> Error.to_result idle

let trampoline =
  Luv_FFI.C.Functions.Idle.get_trampoline ()

let start ~callback idle =
  (* If [Handle.is_active idle], then [uv_idle_start] will not overwrite the
     handle's callback. We need to emulate this behavior in the wrapper. *)
  if Handle.is_active idle then
    Error.Code.success
  else begin
    Handle.set_callback idle callback;
    Luv_FFI.C.Functions.Idle.start (Handle.c idle) trampoline
  end

let stop idle =
  Luv_FFI.C.Functions.Idle.stop (Handle.c idle)
