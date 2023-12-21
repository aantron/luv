(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Per-iteration callback.

    See {{:../../../basics.html#example} {i Example}} in the user guide and
    {{:http://docs.libuv.org/en/v1.x/idle.html} [uv_idle_t] {i — Idle handle}}
    in libuv. *)

type t = [ `Idle ] Handle.t
(** Binds {{:http://docs.libuv.org/en/v1.x/idle.html#c.uv_idle_t} [uv_idle_t]}.

    Note that values of this type can be passed to functions in {!Luv.Handle},
    in addition to the functions in this module. In particular, see
    {!Luv.Handle.close}. *)

val init : ?loop:Loop.t -> unit -> (t, Error.t) result
(** Allocates and initializes an idle handle.

    Binds {{:http://docs.libuv.org/en/v1.x/idle.html#c.uv_idle_init}
    [uv_idle_init]}.

    The handle should be cleaned up with {!Luv.Handle.close} when no longer
    needed. *)

val start : t -> (unit -> unit) -> (unit, Error.t) result
(** Starts the handle with the given callback.

    Binds {{:http://docs.libuv.org/en/v1.x/idle.html#c.uv_idle_start}
    [uv_idle_start]}. *)

val stop : t -> (unit, Error.t) result
(** Stops the handle.

    Binds {{:http://docs.libuv.org/en/v1.x/idle.html#c.uv_idle_stop}
    [uv_idle_stop]}. *)
