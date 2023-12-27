(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let with_loop f =
  Luv.Loop.init () |> ok "init" @@ fun loop ->
  f loop;
  Luv.Loop.close loop |> ok "close" ignore
