(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



val uptime : unit -> (float, Error.t) result
(** Evaluates to the current uptime.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_uptime}
    [uv_uptime]}. See {{:http://man7.org/linux/man-pages/man2/sysinfo.2.html}
    [sysinfo(2)]}. *)

val loadavg : unit -> float * float * float
(** Evaluates to the load average.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_loadavg}
    [uv_loadavg]}. See {{:http://man7.org/linux/man-pages/man2/sysinfo.2.html}
    [sysinfo(2)]}. *)

val free_memory : unit -> Unsigned.uint64
(** Evaluates to the amount of free memory, in bytes.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_get_free_memory}
    [uv_get_free_memory]}. See
    {{:http://man7.org/linux/man-pages/man2/sysinfo.2.html} [sysinfo(2)]}. *)

val total_memory : unit -> Unsigned.uint64
(** Evaluates to the total amount of memory, in bytes.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_get_total_memory}
    [uv_get_total_memory]}. See
    {{:http://man7.org/linux/man-pages/man2/sysinfo.2.html} [sysinfo(2)]}. *)

val constrained_memory : unit -> Unsigned.uint64 option
(** Binds
    {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_get_constrained_memory}}.

    Requires libuv 1.29.0.

    {{!Luv.Require} Feature check}:
    [Luv.Require.(has get_constrained_memory)] *)

(** Priority constants. *)
module Priority :
sig
    val low : int
    val below_normal : int
    val normal : int
    val above_normal : int
    val high : int
    val highest : int
end

val getpriority : int -> (int, Error.t) result
(** Evaluates to the priority of the process with the given pid.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_getpriority}
    [uv_os_getpriority]}. See
    {{:http://man7.org/linux/man-pages/man3/getpriority.3p.html}
    [getpriority(3p)]}.

    Requires libuv 1.23.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has os_priority)] *)

val setpriority : int -> int -> (unit, Error.t) result
(** Sets the priority of the process with the given pid.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_setpriority}
    [uv_os_setpriority]}. See
    {{:http://man7.org/linux/man-pages/man3/setpriority.3p.html}
    [setpriority(3p)]}.

    Requires libuv 1.23.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has os_priority)] *)

val resident_set_memory : unit -> (Unsigned.size_t, Error.t) result
(** Evaluates to the resident set size for the current process.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_resident_set_memory}
    [uv_resident_set_memory]}. *)

type timeval = {
  sec : Signed.Long.t;
  usec : Signed.Long.t;
}
(** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_timeval_t}
    [uv_timeval_t]}. *)

type rusage = {
  utime : timeval;
  stime : timeval;
  maxrss : Unsigned.uint64;
  ixrss : Unsigned.uint64;
  idrss : Unsigned.uint64;
  isrss : Unsigned.uint64;
  minflt : Unsigned.uint64;
  majflt : Unsigned.uint64;
  nswap : Unsigned.uint64;
  inblock : Unsigned.uint64;
  oublock : Unsigned.uint64;
  msgsnd : Unsigned.uint64;
  msgrcv : Unsigned.uint64;
  nsignals : Unsigned.uint64;
  nvcsw : Unsigned.uint64;
  nivcsw : Unsigned.uint64;
}
(** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_rusage_t}
    [uv_rusage_t]}.

    See {{:http://man7.org/linux/man-pages/man2/getrusage.2.html#DESCRIPTION}
    [getrusage(2)]}. *)

val getrusage : unit -> (rusage, Error.t) result
(** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_getrusage}
    [uv_getrusage]}.

    See {{:http://man7.org/linux/man-pages/man3/getrusage.3p.html}
    [getrusage(3p)]}. *)
