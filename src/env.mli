(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



val getenv : string -> (string, Error.t) result
(** Retrieves the value of an environment variable.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_getenv}
    [uv_os_getenv]}. *)

val setenv : string -> value:string -> (unit, Error.t) result
(** Sets an environment variable.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_setenv}
    [uv_os_setenv]}. *)

val unsetenv : string -> (unit, Error.t) result
(** Unsets an environment variable.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_unsetenv}
    [uv_os_unsetenv]}. *)

val environ : unit -> ((string * string) list, Error.t) result
(** Retrieves all environment variables.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_environ}
    [uv_os_environ]}. *)
