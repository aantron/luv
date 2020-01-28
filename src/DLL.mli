(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Dynamic linking.

    See {{:http://docs.libuv.org/en/v1.x/dll.html} {i Shared library
    handling}} in libuv. *)

type t
(** Binds {{:http://docs.libuv.org/en/v1.x/dll.html#c.uv_lib_t} [uv_lib_t]}. *)

val open_ : string -> t option
(** Loads a shared library.

    Binds {{:http://docs.libuv.org/en/v1.x/dll.html#c.uv_dlopen} [uv_dlopen]}.

    Evaluates to [None] on failure. In that case, call {!Luv.DLL.last_error} to
    get the error message. *)

val close : t -> unit
(** Closes a shared library.

    Binds {{:http://docs.libuv.org/en/v1.x/dll.html#c.uv_dlclose}
    [uv_dlclose]}. *)

val sym : t -> string -> nativeint option
(** Loads a symbol from a shared library.

    Binds {{:http://docs.libuv.org/en/v1.x/dll.html#c.uv_dlsym} [uv_dlsym]}.

    Evaluates to [None] on failure. In that case, call {!Luv.DLL.last_error} to
    get the error message. *)

val last_error : t -> string
(** Retrieves the last error message from {!Luv.DLL.open_} or {!Luv.DLL.sym}.

    Binds {{:http://docs.libuv.org/en/v1.x/dll.html#c.uv_dlerror}
    [uv_dlerror]}. *)
