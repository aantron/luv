(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Post-I/O callback.

    See {{:http://docs.libuv.org/en/v1.x/check.html} [uv_check_t] {i - Check
    handle}}. *)

type t = [ `Check ] Handle.t
(** Binds {{:http://docs.libuv.org/en/v1.x/check.html#c.uv_check_t}
    [uv_check_t]}.

    Note that values of this type can be passed to functions in {!Luv.Handle},
    in addition to the functions in this module. In particular, see
    {!Luv.Handle.close}. *)

val init : ?loop:Loop.t -> unit -> (t, Error.t) result
(** Allocates and initializes a check handle.

    Binds {{:http://docs.libuv.org/en/v1.x/check.html#c.uv_check_init}
    [uv_check_init]}.

    The handle should be cleaned up with {!Luv.Handle.close} when no longer
    needed. *)

val start : t -> (unit -> unit) -> (unit, Error.t) result
(** Starts the handle with the given callback.

    Binds {{:http://docs.libuv.org/en/v1.x/check.html#c.uv_check_start}
    [uv_check_start]}. *)

val stop : t -> (unit, Error.t) result
(** Stops the handle.

    Binds {{:http://docs.libuv.org/en/v1.x/check.html#c.uv_check_stop}
    [uv_check_stop]}. *)
