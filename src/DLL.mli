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
    See {{:http://man7.org/linux/man-pages/man3/dlopen.3p.html} [dlopen(3p)]}.

    Evaluates to [None] on failure. In that case, call {!Luv.DLL.error} to get
    the error message. *)

val close : t -> unit
(** Closes a shared library.

    Binds {{:http://docs.libuv.org/en/v1.x/dll.html#c.uv_dlclose}
    [uv_dlclose]}. See {{:http://man7.org/linux/man-pages/man3/dlclose.3p.html}
    [dlclose(3p)]}. *)

val sym : t -> string -> nativeint option
(** Loads a symbol from a shared library.

    Binds {{:http://docs.libuv.org/en/v1.x/dll.html#c.uv_dlsym} [uv_dlsym]}. See
    {{:http://man7.org/linux/man-pages/man3/dlsym.3p.html} [dlsym(3p)]}.

    Evaluates to [None] on failure. In that case, call {!Luv.DLL.error} to get
    the error message. *)

val error : t -> string
(** Retrieves the last error message from {!Luv.DLL.open_} or {!Luv.DLL.sym}.

    Binds {{:http://docs.libuv.org/en/v1.x/dll.html#c.uv_dlerror}
    [uv_dlerror]}. See {{:http://man7.org/linux/man-pages/man3/dlerror.3p.html}
    [dlerror(3p)]}. *)
