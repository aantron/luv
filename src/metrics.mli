(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Metrics.

    See {{:http://docs.libuv.org/en/v1.x/metrics.html} {i Metrics operations}}
    in libuv. *)

val idle_time : Loop.t -> Unsigned.UInt64.t
(** Retrieves the amount of time the loop has been blocked waiting in the
    kernel.

    Binds {{:http://docs.libuv.org/en/v1.x/metrics.html#c.uv_metrics_idle_time}
    [uv_metrics_idle_time]}.

    Requires Luv 0.5.5 and libuv 1.39.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has metrics_idle_time)] *)

type t = {
  loop_count : Unsigned.uint64;
  events : Unsigned.uint64;
  events_waiting : Unsigned.uint64;
}
(** Metrics returned by {!Luv.Metrics.info}.

    Binds {{:https://docs.libuv.org/en/v1.x/metrics.html#c.uv_metrics_t}
    [uv_metrics_t]}.

    Requires Luv 0.5.13 and libuv 1.45.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has metrics_info)] *)

val info : Loop.t -> (t, Error.t) result
(** Retrieves loop metrics.

    Binds {{:https://docs.libuv.org/en/v1.x/metrics.html#c.uv_metrics_info}
    [uv_metrics_info]}.

    Requires Luv 0.5.13 and libuv 1.45.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has metrics_info)] *)
