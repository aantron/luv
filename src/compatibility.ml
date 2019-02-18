(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Sys =
struct
  let opaque_identity x = x
    [@@ocaml.warning "-32"]

  include Sys
  (* On OCaml 4.03 and higher, this include will shadow opaque_identity with a
     genuine implementation. On 4.02, there should be no optimizations possible
     that require a "real" opaque_identity anyway, so it is ok to leave the
     ordinary identity function unshadowed. *)
end
