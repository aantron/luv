(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Mode =
struct
  include C.Types.TTY.Mode
  type t = int
end

type t = [ `TTY ] Stream.t

let init ?loop file =
  let tty = Stream.allocate C.Types.TTY.t in
  C.Functions.TTY.init (Loop.or_default loop) tty (File.to_int file) 0
  |> Error.to_result tty

let set_mode =
  C.Functions.TTY.set_mode

let reset_mode =
  C.Functions.TTY.reset_mode

let get_winsize tty =
  let width = Ctypes.(allocate int) 0 in
  let height = Ctypes.(allocate int) 0 in
  C.Functions.TTY.get_winsize tty width height
  |> Error.to_result_lazy (fun () -> Ctypes.(!@ width, !@ height))

module Vterm_state =
struct
  include C.Types.TTY.Vterm_state
  type t = int
end

let set_vterm_state =
  C.Functions.TTY.set_vterm_state

let get_vterm_state () =
  let state = Ctypes.(allocate_n int) ~count:1 in
  C.Functions.TTY.get_vterm_state state
  |> Error.to_result_lazy (fun () -> Ctypes.(!@) state)
