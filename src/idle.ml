type t = [ `Idle ] Handle.t

let init ?loop () =
  let idle = Handle.allocate C.Types.Idle.t in
  C.Functions.Idle.init (Loop.or_default loop) (Handle.c idle)
  |> Error.to_result idle

let trampoline =
  C.Functions.Idle.get_trampoline ()

let start ~callback idle =
  (* If [Handle.is_active idle], then [uv_idle_start] will not overwrite the
     handle's callback. We need to emulate this behavior in the wrapper. *)
  if Handle.is_active idle then
    Error.success
  else begin
    Handle.set_callback idle callback;
    C.Functions.Idle.start (Handle.c idle) trampoline
  end

let stop idle =
  C.Functions.Idle.stop (Handle.c idle)
