(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Inter-thread communication.

    See {{:http://docs.libuv.org/en/v1.x/async.html} [uv_async_t] {i - Async
    handle}}. *)

type t = [ `Async ] Handle.t
(** Binds {{:http://docs.libuv.org/en/v1.x/async.html#c.uv_async_t}
    [uv_async_t]}.

    Note that values of this type can be passed to functions in {!Luv.Handle},
    in addition to the functions in this module. In particular, see
    {!Luv.Handle.close}. *)

val init : ?loop:Loop.t -> (t -> unit) -> (t, Error.t) result
(** Allocates and initializes an async handle.

    Binds {{:http://docs.libuv.org/en/v1.x/async.html#c.uv_async_init}
    [uv_async_init]}.

    The handle should be cleaned up with {!Luv.Handle.close} when no longer
    needed. *)

val send : t -> (unit, Error.t) result
(** Triggers a call to the handle's callback by the handle's loop.

    Binds {{:http://docs.libuv.org/en/v1.x/async.html#c.uv_async_send}
    [uv_async_send]}. *)
