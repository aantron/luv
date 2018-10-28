type t = [ `Prepare ] Handle.t

let init ?loop () =
  let prepare = Handle.allocate C.Types.Prepare.t in
  C.Functions.Prepare.init (Loop.or_default loop) (Handle.c prepare)
  |> Error.to_result prepare

let trampoline =
  C.Functions.Prepare.get_trampoline ()

let start prepare callback =
  (* If [Handle.is_active prepare], then [uv_prepare_start] will not overwrite
     the handle's callback. We need to emulate this behavior in the wrapper. *)
  if Handle.is_active prepare then
    Error.success
  else begin
    Handle.set_callback prepare callback;
    C.Functions.Prepare.start (Handle.c prepare) trampoline
  end

let stop prepare =
  C.Functions.Prepare.stop (Handle.c prepare)
