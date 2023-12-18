(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



val available_parallelism : unit -> int
(** Binds
    {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_available_parallelism}
    [uv_available_parallelism]}.

    Requires Luv 0.5.12 and libuv 1.44.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has available_parallelism)] *)

(** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_cpu_info_t}
    [uv_cpu_info_t]}. *)
module CPU_info :
sig
  type times = {
    user : Unsigned.uint64;
    nice : Unsigned.uint64;
    sys : Unsigned.uint64;
    idle : Unsigned.uint64;
    irq : Unsigned.uint64;
  }

  type t = {
    model : string;
    speed : int;
    times : times;
  }
end

val cpu_info : unit -> (CPU_info.t list, Error.t) result
(** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_cpu_info}
    [uv_cpu_info]}. *)

val cpumask_size : unit -> (int, Error.t) result
(** Binds {{:https://docs.libuv.org/en/v1.x/misc.html#c.uv_cpumask_size}
    [uv_cpumask_size]}.

    Requires Luv 0.5.13 and libuv 1.45.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has cpumask_size)] *)

(** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_utsname_t}
    [uv_utsname_t]}. *)
module Uname :
sig
  type t = {
    sysname : string;
    release : string;
    version : string;
    machine : string;
  }
end

val uname : unit -> (Uname.t, Error.t) result
(** Retrieves operating system name and version information.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_uname}
    [uv_os_uname]}. See {{:http://man7.org/linux/man-pages/man3/uname.3p.html}
    [uname(3p)]}.

    Requires libuv 1.25.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has os_uname)] *)
