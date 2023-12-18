(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type user = {
  username : string;
  uid : Unsigned.ulong;
  gid : Unsigned.ulong;
  shell : string option;
  homedir : string;
}
(** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_passwd_t}
    [uv_passwd_t]}. *)

(**/**)
type t = user
(**/**)

val get_passwd : ?uid:Unsigned.ulong -> unit -> (user, Error.t) result
(** Gets passwd entry for the current user or the user with the given uid.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_get_passwd}
    [uv_os_get_passwd]}. See
    {{:http://man7.org/linux/man-pages/man3/getpwuid_r.3p.html}
    [getpwuid_r(3p)]}.

    Requires libuv 1.9.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has os_get_passwd)]

    The [?uid] argument requires Luv 0.5.13 and libuv 1.45.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has os_get_passwd_uid)] *)

type group = {
  groupname : string;
  gid : Unsigned.ulong;
  members : string list;
}
(** Binds [uv_group_t]. *)

val get_group : Unsigned.ulong -> (group, Error.t) result
(** Gets the entry for the group with the given gid.

    Binds [uv_os_get_group].

    Requires Luv 0.5.13 and libuv 1.45.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has os_get_group)] *)
