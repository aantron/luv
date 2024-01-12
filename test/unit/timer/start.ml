let () =
  Helpers.with_timer @@ fun timer ->

  let timeout = 10 in
  let start_time = Unix.gettimeofday () in

  let callback_time = ref 0. in

  Luv.Timer.start timer timeout (fun () ->
    callback_time := Unix.gettimeofday ())
  |> ok "start" @@ fun () ->

  Luv.Loop.run () |> ignore;

  let elapsed_outside = (Unix.gettimeofday ()) -. start_time in
  let elapsed_callback = !callback_time -. start_time in

  let minimum_allowed = (float_of_int (timeout - 1)) *. 1e-3 in
  let maximum_allowed = minimum_allowed *. 6. in

  let check_elapsed elapsed f =
    if elapsed < minimum_allowed then
      Printf.printf "Error: %.1f ms elapsed, has to be at least %.1f ms\n"
        (elapsed *. 1e3) (minimum_allowed *. 1e3)
    else
      if elapsed > maximum_allowed then
        Printf.printf "Error: %.1f ms elapsed, has to be at most %.1f ms\n"
          (elapsed *. 1e3) (maximum_allowed *. 1e3)
      else
        f ()
  in

  check_elapsed elapsed_outside @@ fun () ->
  check_elapsed elapsed_callback @@ fun () ->
  print_endline "Ok"
