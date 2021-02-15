(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = {
  tv_sec : int64;
  tv_usec : int32;
}
(** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_timeval64_t}
    [uv_timeval64_t]}. *)

val gettimeofday : unit -> (t, Error.t) result
(** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_gettimeofday}
    [uv_gettimeofday]}. See
    {{:http://man7.org/linux/man-pages/man3/gettimeofday.3p.html}
    [gettimeofday(3p)]}.

    Requires libuv 1.28.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has gettimeofday)] *)

val hrtime : unit -> Unsigned.uint64
(** Samples the high-resolution timer.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_hrtime}
    [uv_hrtime]}. See
    {{:http://man7.org/linux/man-pages/man3/clock_gettime.3p.html}
    [clock_gettime(3p)]}. *)

val sleep : int -> unit
(** Suspends the calling thread for at least the given number of milliseconds.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_sleep}
    [uv_sleep]}. See {{:http://man7.org/linux/man-pages/man3/sleep.3p.html}
    [sleep(3p)]}.

    Requires libuv 1.34.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has sleep)] *)
