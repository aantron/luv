(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `FS_event ] Handle.t

module Event =
struct
  type t = [
    | `RENAME
    | `CHANGE
  ]

  let to_c = let open C.Types.FS_event.Event in function
    | `RENAME -> rename
    | `CHANGE -> change

  let all = [
    `RENAME;
    `CHANGE;
  ]
end

module Flag =
struct
  type t = [
    | `WATCH_ENTRY
    | `STAT
    | `RECURSIVE
  ]

  let to_c = let open C.Types.FS_event.Flag in function
    | `WATCH_ENTRY -> watch_entry
    | `STAT -> stat
    | `RECURSIVE -> recursive
end

let init ?loop () =
  let event = Handle.allocate C.Types.FS_event.t in
  C.Functions.FS_event.init (Loop.or_default loop) event
  |> Error.to_result event

let trampoline =
  C.Functions.FS_event.get_trampoline ()

let start ?(flags = []) event path callback =
  let flags = Helpers.Bit_flag.list_to_c Flag.to_c flags in
  Handle.set_reference event begin fun filename events result ->
    let result =
      Error.to_result_lazy (fun () ->
        filename, Helpers.Bit_flag.c_to_list Event.to_c Event.all events)
        result
    in
    Error.catch_exceptions callback result
  end;
  let immediate_result =
    C.Functions.FS_event.start
      event trampoline (Ctypes.ocaml_string_start path) flags
  in
  if immediate_result < Error.success then
    callback (Result.Error immediate_result)

let stop event =
  C.Functions.FS_event.stop event
  |> Error.to_result ()
