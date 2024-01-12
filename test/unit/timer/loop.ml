let () =
  Helpers.with_timer @@ fun timer ->
  Ctypes.ptr_compare (Luv.Handle.get_loop timer) (Luv.Loop.default ()) = 0
  |> Printf.printf "%b\n"
