type t = [ `FS_event ] Handle.t

module Event =
struct
  include C.Types.FS_event.Event
  include Helpers.Bit_flag
end

module Flag =
struct
  include C.Types.FS_event.Flag
  include Helpers.Bit_flag
end

let init ?loop () =
  let event = Handle.allocate C.Types.FS_event.t in
  C.Functions.FS_event.init (Loop.or_default loop) event
  |> Error.to_result event

let trampoline =
  C.Functions.FS_event.get_trampoline ()

let start ?(flags = 0) event path callback =
  let callback = Error.catch_exceptions callback in
  Handle.set_reference event (fun filename events result ->
    callback (Error.to_result (filename, events) result));
  let immediate_result =
    C.Functions.FS_event.start
      event trampoline (Ctypes.ocaml_string_start path) flags
  in
  if immediate_result < Error.success then
    callback (Result.Error immediate_result)

let stop =
  C.Functions.FS_event.stop
