(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Thread-local storage.

    See {{:http://docs.libuv.org/en/v1.x/threading.html#thread-local-storage}
    {i Thread-local storage}} in libuv.

    The interface is currently written in terms of [nativeint], the type of
    pointer-sized raw values. You can store OCaml values in TLS by manipulating
    and registering them with the GC using
    {{:https://github.com/ocamllabs/ocaml-ctypes/blob/1e1429fe249778f0c4db458aa33df5991f2a93ca/src/ctypes/ctypes.mli#L570}
    [Ctypes.Root]}. The conversions between [unit ptr] and [nativeint] are
    {{:https://github.com/ocamllabs/ocaml-ctypes/blob/1e1429fe249778f0c4db458aa33df5991f2a93ca/src/ctypes/ctypes.mli#L213}
    [Ctypes.ptr_of_raw_address]} and
    {{:https://github.com/ocamllabs/ocaml-ctypes/blob/1e1429fe249778f0c4db458aa33df5991f2a93ca/src/ctypes/ctypes.mli#L219}
    [Ctypes.raw_address_of_ptr]}.

    A future version of this API is likely to handle GC roots internally, and be
    directly usable with OCaml values. *)

type t
(** Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_key_t}
    [uv_key_t]}. *)

val create : unit -> (t, Error.t) result
(** Creates a TLS key.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_key_create}
    [uv_key_create]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_key_create.3p.html}
    [pthread_key_create(3p)]}. *)

val delete : t -> unit
(** Deletes a TLS key.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_key_delete}
    [uv_key_delete]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_key_delete.3p.html}
    [pthread_key_delete(3p)]}. *)

val get : t -> nativeint
(** Retrieves the value at a TLS key.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_key_get}
    [uv_key_get]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_getspecific.3p.html}
    [pthread_getspecific(3p)]}. *)

val set : t -> nativeint -> unit
(** Sets the value at a TLS key.

    Binds {{:http://docs.libuv.org/en/v1.x/threading.html#c.uv_key_set}
    [uv_key_set]}. See
    {{:http://man7.org/linux/man-pages/man3/pthread_setspecific.3p.html}
    [pthread_setspecific(3p)]}. *)
