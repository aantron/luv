let () =
  Ctypes.is_null (Luv.Loop.default ())
  |> Printf.printf "%b\n"
