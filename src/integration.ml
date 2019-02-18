(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type library = {
  before_io : unit -> Loop.Run_mode.t;
  after_io : more_io:bool -> [ `Keep_running | `Stop ];
}

let libraries = ref []

let register ~before_io ~after_io () =
  libraries := {before_io; after_io}::!libraries

let should_stop =
  ref false

let minimum_run_mode run_mode_1 run_mode_2 =
  let module RM = Loop.Run_mode in
  if run_mode_1 = RM.nowait || run_mode_2 = RM.nowait then RM.nowait
  else if run_mode_1 = RM.once || run_mode_2 = RM.once then RM.once
  else RM.default

module Start_and_stop =
struct
  let run () =
    while not !should_stop do
      let more_io =
        !libraries
        |> List.map (fun library -> library.before_io ())
        |> List.fold_left minimum_run_mode Loop.Run_mode.default
        |> fun mode -> Loop.run ~mode ()
      in

      !libraries
      |> List.map (fun library -> library.after_io ~more_io)
      |> List.for_all ((=) `Stop)
      |> fun all_want_to_stop -> if all_want_to_stop then should_stop := true
    done;
    should_stop := false

  let stop () =
    should_stop := true;
    Loop.(stop (default ()))
end
