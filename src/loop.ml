(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



include C.Functions.Loop

type t = C.Types.Loop.t Ctypes.ptr

let init () =
  let loop = Ctypes.addr (Ctypes.make C.Types.Loop.t) in
  let result = C.Functions.Loop.init loop in
  Error.to_result loop result

let configure loop option value =
  C.Functions.Loop.configure loop option (Obj.magic value)
  |> Error.to_result ()

let close loop =
  C.Functions.Loop.close loop
  |> Error.to_result ()

let or_default maybe_loop =
  match maybe_loop with
  | Some loop -> loop
  | None -> C.Functions.Loop.default ()

module Run_mode =
struct
  include C.Types.Loop.Run_mode
  type t = int
end

module Option =
struct
  include C.Types.Loop.Option
  type 'value t = int
end

(* run must always release the runtime lock, even if called with
   Run_mode.nowait. This is because calling run can trigger callbacks, and
   callbacks expect to be able to take the lock (eventually). If the lock is
   *not* released by run and a callback is called, there will be a deadlock. *)
let run ?loop ?(mode = Run_mode.default) () =
  let loop = or_default loop in
  C.Blocking.Loop.run loop mode

let fork loop =
  C.Functions.Loop.fork loop
  |> Error.to_result ()
