(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



val uptime : unit -> (float, Error.t) result
(** Evaluates to the current uptime.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_uptime}
    [uv_uptime]}. *)

val loadavg : unit -> float * float * float
(** Evaluates to the load average.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_loadavg}
    [uv_loadavg]}. *)

val free_memory : unit -> Unsigned.uint64
(** Evaluates to the amount of free memory, in bytes.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_get_free_memory}
    [uv_get_free_memory]}. *)

val total_memory : unit -> Unsigned.uint64
(** Evaluates to the total amount of memory, in bytes.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_get_total_memory}
    [uv_get_total_memory]}. *)

val constrained_memory : unit -> Unsigned.uint64 option
(** Binds
    {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_get_constrained_memory}}. *)

val getpriority : int -> (int, Error.t) result
(** Evaluates to the priority of the process with the given pid.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_getpriority}
    [uv_os_getpriority]}. *)

val setpriority : int -> int -> (unit, Error.t) result
(** Sets the priority of the process with the given pid.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_setpriority}
    [uv_os_setpriority]}. *)

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

    See {{:http://man7.org/linux/man-pages/man2/getrusage.2.html}
    [getrusage(2)]}. *)
