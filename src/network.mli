(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



val if_indextoname : int -> (string, Error.t) result
(** Retrieves a network interface name.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_if_indextoname}
    [uv_if_indextoname]}. See
    {{:http://man7.org/linux/man-pages/man3/if_indextoname.3p.html}
    [if_indextoname(3p)]}. *)

val if_indextoiid : int -> (string, Error.t) result
(** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_if_indextoiid}
    [uv_if_indextoiid]}. *)

val gethostname : unit -> (string, Error.t) result
(** Evaluates to the system's hostname.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_gethostname}
    [uv_os_gethostname]}. See
    {{:http://man7.org/linux/man-pages/man3/gethostname.3p.html}
    [gethostname(3p)]}. *)
