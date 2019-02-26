(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



include
  Loop_watcher.Watcher
    (struct
      type kind = [ `Check ]
      include C.Functions.Check
    end)
