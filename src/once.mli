(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Once-only initialization.

    See
    {{:http://docs.libuv.org/en/v1.x/threading.html#once-only-initialization}
    {i Once-only initialization}}. *)

type t
(** Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_once_t}
    [uv_once_t]}. *)

val init : unit -> (t, Error.t) result
(** Allocates and initializes a once-only barrier.

    Binds
    {{:http://docs.libuv.org/en/v1.x/threading.html#once-only-initialization}
    [UV_ONCE_INIT]}. *)

val once : t -> (unit -> unit) -> unit
(** Guards the given callback to be called only once.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_once}
    [uv_once]}. *)

val once_c : t -> nativeint -> unit
(** Like {!Luv.Once.once}, but takes a pointer to a C function. *)
