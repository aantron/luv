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
    [gettimeofday(3p)]}. *)

val hrtime : unit -> Unsigned.uint64
(** Samples the high-resolution timer.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_hrtime}
    [uv_hrtime]}. *)

val sleep : int -> unit
(** Suspends the calling thread for at least the given number of milliseconds.

    Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_sleep}
    [uv_sleep]}. *)
