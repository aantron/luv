(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



open Luv.Syntax

let delay milliseconds k =
  let timer =
    match Luv.Timer.init () with
    | Result.Ok timer -> timer
    | Result.Error _ -> assert false
  in
  ignore @@ Luv.Timer.start timer milliseconds (fun () ->
    Luv.Handle.close timer ignore;
    k ())

let () =
  let- () = delay 5000
  and- () = delay 5000 in
  ()

let () =
  ignore @@ Luv.Loop.run ()
