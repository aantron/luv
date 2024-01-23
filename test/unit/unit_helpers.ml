(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let show_error step error =
  Printf.printf
    "%s: %s (%s)\n" step (Luv.Error.err_name error) (Luv.Error.strerror error)

let ok step f result =
  match result with
  | Error error -> show_error step error
  | Ok value -> f value

let error errors step f result =
  match result with
  | Error error when List.mem error errors -> f ()
  | Error error -> show_error step error
  | Ok _ -> Printf.printf "%s: expected an error" step

let show_option print = function
  | Some value -> print value
  | None -> print_endline "None"

let no_memory_leak =
  let count_allocated_words () =
    Gc.full_major ();
    Gc.((stat ()).live_words)
  in
  let count_allocated_words_during repetitions f =
    let initial = count_allocated_words () in
    for i = 1 to repetitions do
      f i
    done;
    max 0 (count_allocated_words () - initial)
  in
  fun ?(base_repetitions = 100) f ->
    f 0;
    let allocated_during_first_run =
      count_allocated_words_during base_repetitions f
      |> float_of_int
    in
    let allocated_during_second_run =
      count_allocated_words_during (base_repetitions * 3) f
      |> float_of_int
    in
    if allocated_during_second_run /. allocated_during_first_run > 1.1 then
      Printf.printf
        "Memory leak: %.0f words allocated, then %.0f words allocated\n"
        allocated_during_first_run
        allocated_during_second_run

let fresh_callback =
  let callback_index = ref 0 in
  let accumulator = ref 0 in
  fun () ->
    let index = !callback_index in
    callback_index := !callback_index + 1;
    fun () ->
      accumulator := !accumulator + index
