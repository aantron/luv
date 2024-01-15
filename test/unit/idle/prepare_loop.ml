let () =
  Helpers.with_prepare @@ fun prepare ->
  Ctypes.ptr_compare (Luv.Handle.get_loop prepare) (Luv.Loop.default ()) = 0
  |> Printf.printf "%b\n"
