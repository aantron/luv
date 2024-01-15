let () =
  Helpers.with_idle @@ fun idle ->
  Ctypes.ptr_compare (Luv.Handle.get_loop idle) (Luv.Loop.default ()) = 0
  |> Printf.printf "%b\n"
