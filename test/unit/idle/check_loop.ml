let () =
  Helpers.with_check @@ fun check ->
  Ctypes.ptr_compare (Luv.Handle.get_loop check) (Luv.Loop.default ()) = 0
  |> Printf.printf "%b\n"
