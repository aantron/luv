type t = [ `Check ] Handle.t

let init ?loop () =
  let check = Handle.allocate C.Types.Check.t in
  C.Functions.Check.init (Loop.or_default loop) (Handle.c check)
  |> Error.to_result check

let trampoline =
  C.Functions.Check.get_trampoline ()

let start check callback =
  (* If [Handle.is_active check], then [uv_check_start] will not overwrite the
     handle's callback. We need to emulate this behavior in the wrapper. *)
  if Handle.is_active check then
    Error.success
  else begin
    Handle.set_callback check callback;
    C.Functions.Check.start (Handle.c check) trampoline
  end

let stop check =
  C.Functions.Check.stop (Handle.c check)
