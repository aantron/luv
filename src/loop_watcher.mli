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
