(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



include Luv.Promisify.With_promise_type
  (struct
    type 'a promise = 'a Promise.t
    let make = Promise.pending
  end)

include Luv.Integration.Start_and_stop

module Callbacks = Promise.ReadyCallbacks

let before_io () =
  if Callbacks.callbacksPending () then
    Luv.Loop.Run_mode.nowait
  else
    Luv.Loop.Run_mode.once

let after_io ~more_io =
  if Callbacks.callbacksPending () then begin
    Callbacks.(snapshot () |> call);
    `Keep_running
  end
  else
    if more_io then `Keep_running else `Stop

let () =
  Luv.Integration.register ~before_io ~after_io ()
