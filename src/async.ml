(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `Async ] Handle.t

let trampoline =
  C.Functions.Async.get_trampoline ()

let init ?loop callback =
  let async = Handle.allocate C.Types.Async.t in
  let callback = fun () -> callback async in
  Handle.set_reference async (Error.catch_exceptions callback);
  C.Functions.Async.init (Loop.or_default loop) async trampoline
  |> Error.to_result async

let send =
  C.Functions.Async.send
