(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let () =
  Ctypes.is_null (Luv.Loop.default ())
  |> Printf.printf "%b\n"
