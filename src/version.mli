(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Version information for the vendored libuv. See
    {{:http://docs.libuv.org/en/v1.x/version.html} {i Version-checking macros
    and functions}} in the libuv documentation.

    Luv currently vendors libuv
    {{:https://github.com/libuv/libuv/releases/tag/v1.30.1} 1.30.1}. *)

val string : unit -> string
(** Returns the libuv version as a string. See
    {{:http://docs.libuv.org/en/v1.x/version.html#c.uv_version_string}
    [uv_version_string]}. *)

val major : int
(** libuv major version number. See
    {{:http://docs.libuv.org/en/v1.x/version.html#c.UV_VERSION_MAJOR}
    [UV_VERSION_MAJOR]}. *)

val minor : int
(** libuv minor version number. See
    {{:http://docs.libuv.org/en/v1.x/version.html#c.UV_VERSION_MINOR}
    [UV_VERSION_MINOR]}. *)

val patch : int
(** libuv patch number. See
    {{:http://docs.libuv.org/en/v1.x/version.html#c.UV_VERSION_PATCH}
    [UV_VERSION_PATCH]}. *)

val is_release : bool
(** [true] if the libuv version is a release, and [false] if it is a development
    version. This will almost always be [true] for Luv releases. See
    {{:http://docs.libuv.org/en/v1.x/version.html#c.UV_VERSION_IS_RELEASE}
    [UV_VERSION_IS_RELEASE]}. *)

val suffix : string
(** libuv version suffix for development releases. See
    {{:http://docs.libuv.org/en/v1.x/version.html#c.UV_VERSION_SUFFIX}
    [UV_VERSION_SUFFIX]}. *)

val hex : int
(** libuv version packed into a single integer. See
    {{:http://docs.libuv.org/en/v1.x/version.html#c.UV_VERSION_SUFFIX}
    [UV_VERSION_HEX]}. *)

val version : unit -> int
(** Returns {!Luv.Version.hex}. See
    {{:http://docs.libuv.org/en/v1.x/version.html#c.uv_version}
    [uv_version]}. *)
