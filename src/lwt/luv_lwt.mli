(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



include Luv.Promisify.PROMISIFIED with type 'a promise := 'a Lwt.t
include module type of Luv.Integration.Start_and_stop
