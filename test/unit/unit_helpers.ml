(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let show_error step error =
  Printf.printf
    "%s: %s (%s)" step (Luv.Error.err_name error) (Luv.Error.strerror error)

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
