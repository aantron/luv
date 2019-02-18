(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



open Test_helpers

let tests = [
  "tty",
  (* There is no TTY when running in Travis, at least under macOS. *)
  if in_travis then
    []
  else [
      "tty", `Quick, begin fun () ->
        let tty = Luv.TTY.init Luv.File.stdin |> check_success_result "init" in
        let width, height =
          Luv.TTY.get_winsize tty |> check_success_result "get_winsize" in
        if width <= 0 then
          Alcotest.failf "width <= 0: %i" width;
        if height <= 0 then
          Alcotest.failf "height <= 0: %i" height;
        Luv.Handle.close tty
      end;
    ]
]
