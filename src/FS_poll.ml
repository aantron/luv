(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `FS_poll ] Handle.t

let init ?loop () =
  let poll = Handle.allocate C.Types.FS_poll.t in
  C.Functions.FS_poll.init (Loop.or_default loop) poll
  |> Error.to_result poll

let stat_ptr_to_ocaml pointer =
  pointer
  |> Ctypes.ptr_of_raw_address
  |> Ctypes.from_voidp C.Types.File.Stat.t
  |> Ctypes.(!@)
  |> File.Stat.load

let trampoline =
  C.Functions.FS_poll.get_trampoline ()

let start ?(interval = 2000) poll path callback =
  let callback = Error.catch_exceptions callback in
  Handle.set_reference poll begin fun result previous_stat current_stat ->
    result
    |> Error.to_result_f (fun () ->
      (stat_ptr_to_ocaml previous_stat, stat_ptr_to_ocaml current_stat))
    |> callback
  end;
  let immediate_result =
    C.Functions.FS_poll.start
      poll trampoline (Ctypes.ocaml_string_start path) interval
  in
  if immediate_result < 0 then
    callback (Error.result_from_c immediate_result)

let stop poll =
  C.Functions.FS_poll.stop poll
  |> Error.to_result ()
