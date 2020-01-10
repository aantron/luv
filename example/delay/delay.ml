(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let () =
  let timer =
    match Luv.Timer.init () with
    | Ok timer -> timer
    | Error error ->
      Printf.eprintf "Could not create timer: %s\n" (Luv.Error.strerror error);
      exit 1
  in

  print_string "Delaying for one second...";
  flush stdout;

  let result =
    Luv.Timer.start timer 1000 begin fun () ->
      Luv.Handle.close timer ignore;
      print_endline " done!"
    end;
  in
  begin match result with
  | Result.Ok () -> ()
  | Result.Error error ->
    Printf.eprintf "Could not start timer: %s\n" (Luv.Error.strerror error);
    exit 1
  end;

  ignore (Luv.Loop.run ())
