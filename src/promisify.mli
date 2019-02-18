(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



include module type of Promisify_signatures

module With_promise_type :
  functor (P : PROMISE) -> PROMISIFIED with type 'a promise := 'a P.promise
