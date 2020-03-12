(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



open Test_helpers

let with_tty f =
  let tty =
    Luv.TTY.init Luv.File.stdin
    |> check_success_result "init"
  in

  f tty;

  Luv.Handle.close tty ignore;
  run ()

let tests = [
  "tty",
  (* There is no TTY when running in Travis, at least under macOS. *)
  if in_travis || Sys.win32 then
    []
  else [
      "tty", `Quick, begin fun () ->
        with_tty begin fun tty ->
          let width, height =
            Luv.TTY.get_winsize tty |> check_success_result "get_winsize" in
          if width <= 0 then
            Alcotest.failf "width <= 0: %i" width;
          if height <= 0 then
            Alcotest.failf "height <= 0: %i" height
        end
      end;

      (* This is a compilation test. If the type constraints in handle.mli are
         wrong, there will be a type error in this test. *)
      "handle functions", `Quick, begin fun () ->
        with_tty begin fun tty ->
          ignore @@ Luv.Handle.fileno tty
        end
      end;
    ]
]
