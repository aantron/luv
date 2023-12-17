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

let init ?loop () =
  let event = Handle.allocate C.Types.FS_event.t in
  C.Functions.FS_event.init (Loop.or_default loop) event
  |> Error.to_result event

let trampoline =
  C.Functions.FS_event.get_trampoline ()

let start
    ?(watch_entry = false)
    ?(stat = false)
    ?(recursive = false)
    event
    path
    callback =

  let flags =
    let accumulate = Helpers.Bit_field.accumulate in
    0
    |> accumulate C.Types.FS_event.Flag.watch_entry watch_entry
    |> accumulate C.Types.FS_event.Flag.stat stat
    |> accumulate C.Types.FS_event.Flag.recursive recursive
  in
  Handle.set_reference event begin fun filename events result ->
    let result =
      Error.to_result_f (fun () ->
        filename, Helpers.Bit_field.c_to_list Event.to_c Event.all events)
        result
    in
    Error.catch_exceptions callback result
  end;
  let immediate_result =
    C.Functions.FS_event.start
      event trampoline (Ctypes.ocaml_string_start path) flags
  in
  if immediate_result < 0 then
    callback (Error.result_from_c immediate_result)

let stop event =
  C.Functions.FS_event.stop event
  |> Error.to_result ()
