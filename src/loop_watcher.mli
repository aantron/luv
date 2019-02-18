(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Prepare :
sig
  type t = [ `Prepare ] Handle.t

  val init : ?loop:Loop.t -> unit -> (t, Error.t) Result.result
  val start : t -> (unit -> unit) -> Error.t
  val stop : t -> Error.t
end

module Check :
sig
  type t = [ `Check ] Handle.t

  val init : ?loop:Loop.t -> unit -> (t, Error.t) Result.result
  val start : t -> (unit -> unit) -> Error.t
  val stop : t -> Error.t
end

module Idle :
sig
  type t = [ `Idle ] Handle.t

  val init : ?loop:Loop.t -> unit -> (t, Error.t) Result.result
  val start : t -> (unit -> unit) -> Error.t
  val stop : t -> Error.t
end
