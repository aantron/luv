type prepare = Luv_FFI.C.Types.Prepare.prepare
type t = prepare Handle.t

let init ?loop () =
  let prepare = Handle.allocate Luv_FFI.C.Types.Prepare.t in
  Luv_FFI.C.Functions.Prepare.init (Loop.or_default loop) (Handle.c prepare)
  |> Error.to_result prepare

let trampoline =
  Luv_FFI.C.Functions.Prepare.get_trampoline ()

let start ~callback prepare =
  (* If [Handle.is_active prepare], then [uv_prepare_start] will not overwrite
     the handle's callback. We need to emulate this behavior in the wrapper. *)
  if Handle.is_active prepare then
    Error.Code.success
  else begin
    Handle.set_callback prepare callback;
    Luv_FFI.C.Functions.Prepare.start (Handle.c prepare) trampoline
  end

let stop prepare =
  Luv_FFI.C.Functions.Prepare.stop (Handle.c prepare)
