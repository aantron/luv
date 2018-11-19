include Luv.Promisify.With_promise_type
  (struct
    type 'a promise = 'a Lwt.t
    let make () =
      let p, resolver = Lwt.wait () in
      (p, fun v -> Lwt.wakeup_later resolver v)
  end)

include Luv.Integration.Start_and_stop

let before_io () =
  if Lwt.paused_count () = 0 then
    Luv.Loop.Run_mode.default
  else
    Luv.Loop.Run_mode.nowait

let after_io ~more_io =
  if Lwt.paused_count () = 0 then begin
    if more_io then `Keep_running else `Stop
  end
  else begin
    Lwt.wakeup_paused ();
    `Keep_running
  end

let () =
  Luv.Integration.register ~before_io ~after_io ()
