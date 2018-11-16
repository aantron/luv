type t = [ `Timer ] Handle.t

let init ?loop () =
  let timer = Handle.allocate C.Types.Timer.t in
  C.Functions.Timer.init (Loop.or_default loop) timer
  |> Error.to_result timer

let trampoline =
  C.Functions.Timer.get_trampoline ()

let start ?(call_update_time = true) ?(repeat = 0) timer timeout callback =
  Handle.set_reference timer (Error.catch_exceptions callback);

  if call_update_time then begin
    Loop.update_time (Handle.get_loop timer)
  end;

  C.Functions.Timer.start
    timer
    trampoline
    (Unsigned.UInt64.of_int timeout)
    (Unsigned.UInt64.of_int repeat)

let stop =
  C.Functions.Timer.stop

let again =
  C.Functions.Timer.again

let set_repeat timer repeat =
  C.Functions.Timer.set_repeat timer (Unsigned.UInt64.of_int repeat)

let get_repeat timer =
  C.Functions.Timer.get_repeat timer
  |> Unsigned.UInt64.to_int
