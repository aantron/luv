(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



val getenv : string -> (string, Error.t) result
(** Retrieves the value of an environment variable.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_getenv}
    [uv_os_getenv]}. See {{:http://man7.org/linux/man-pages/man3/getenv.3p.html}
    [getenv(3p)]}. *)

val setenv : string -> value:string -> (unit, Error.t) result
(** Sets an environment variable.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_setenv}
    [uv_os_setenv]}. See {{:http://man7.org/linux/man-pages/man3/setenv.3p.html}
    [setenv(3p)]}. *)

val unsetenv : string -> (unit, Error.t) result
(** Unsets an environment variable.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_unsetenv}
    [uv_os_unsetenv]}. See
    {{:http://man7.org/linux/man-pages/man3/unsetenv.3p.html}
    [unsetenv(3p)]}. *)

val environ : unit -> ((string * string) list, Error.t) result
(** Retrieves all environment variables.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_environ}
    [uv_os_environ]}. See
    {{:http://man7.org/linux/man-pages/man3/environ.3p.html} [environ(3p)]}. *)
