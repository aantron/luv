(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



val getpid : unit -> int
(** Evaluates to the pid of the current process.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_getpid}
    [uv_os_getpid]}. See {{:http://man7.org/linux/man-pages/man3/getpid.3p.html}
    [getpid(3p)]}.

    Requires libuv 1.18.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has os_getpid)] *)

val getppid : unit -> int
(** Evaluates to the pid of the parent process.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_getppid}
    [uv_os_getppid]}. See
    {{:http://man7.org/linux/man-pages/man3/getppid.3p.html} [getppid(3p)]}.

    Requires libuv 1.16.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has os_getppid)] *)
