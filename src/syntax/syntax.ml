(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type 'a cps = ('a -> unit) -> unit

let ( let* ) op f =
  fun k ->
    op (fun v ->
      f v k)

let ( and* ) op1 op2 =
  fun k ->
    let c1 = ref None in
    let c2 = ref None in
    op1 (fun v1 ->
      match !c2 with
      | None -> c1 := Some v1
      | Some v2 -> k (v1, v2));
    op2 (fun v2 ->
      match !c1 with
      | None -> c2 := Some v2
      | Some v1 -> k (v1, v2))

let ( let+ ) op f =
  fun k ->
    op (fun v ->
      k (f v))

let ( and+ ) =
  ( and* )

let ( let- ) op k =
  op k

let ( and- ) =
  ( and* )
