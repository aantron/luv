include Luv.Promisify.With_promise_type
  (struct
    type 'a promise = 'a Repromise.t
    let make = Repromise.make
  end)

include Luv.Integration.Start_and_stop

module Callbacks = Repromise.ReadyCallbacks

let before_io () =
  if Callbacks.callbacksPending () then
    Luv.Loop.Run_mode.nowait
  else
    Luv.Loop.Run_mode.default

let after_io ~more_io =
  if Callbacks.callbacksPending () then begin
    Callbacks.(snapshot () |> call);
    `Keep_running
  end
  else
    if more_io then `Keep_running else `Stop

let () =
  Luv.Integration.register ~before_io ~after_io ()
