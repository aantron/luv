(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



val exepath : unit -> (string, Error.t) result
(** Evaluates to the executable's path.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_exepath}
    [uv_exepath]}. *)

val cwd : unit -> (string, Error.t) result
(** Evaluates to the current working directory.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_cwd} [uv_cwd]}. See
    {{:http://man7.org/linux/man-pages/man3/getcwd.3p.html} [getcwd(3p)]}. *)

val chdir : string -> (unit, Error.t) result
(** Changes the current working directory.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_chdir}
    [uv_chdir]}. See {{:http://man7.org/linux/man-pages/man3/chdir.3p.html}
    [chdir(3p)]}. *)

val homedir : unit -> (string, Error.t) result
(** Evaluates to the path of the home directory.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_homedir}
    [uv_os_homedir]}.

    Requires libuv 1.6.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has os_homedir)] *)

val tmpdir : unit -> (string, Error.t) result
(** Evaluates to the path of the temporary directory.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_tmpdir}
    [uv_os_tmpdir]}.

    Requires libuv 1.9.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has os_tmpdir)] *)
