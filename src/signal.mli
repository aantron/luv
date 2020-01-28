(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Signals.

    See {{:https://aantron.github.io/luv/processes.html#signals} {i Signals}} in
    the user guide and {{:http://docs.libuv.org/en/v1.x/signal.html}
    [uv_signal_t] {i — Signal handle}} in libuv. *)



(** {1 Interface} *)

type t = [ `Signal ] Handle.t
(** Binds {{:http://docs.libuv.org/en/v1.x/signal.html#c.uv_signal_t}
    [uv_signal_t]}.

    Note that values of this type can be passed to functions in {!Luv.Handle},
    in addition to the functions in this module. In particular, see
    {!Luv.Handle.close}. *)

val init : ?loop:Loop.t -> unit -> (t, Error.t) result
(** Allocates and initializes a signal handle.

    Binds {{:http://docs.libuv.org/en/v1.x/signal.html#c.uv_signal_init}
    [uv_signal_init]}. *)

val start : t -> int -> (unit -> unit) -> (unit, Error.t) result
(** Starts the signal handle.

    Binds {{:http://docs.libuv.org/en/v1.x/signal.html#c.uv_signal_start}
    [uv_signal_start]}.

    See {{!signals} {i Signal numbers}} below for possible values of the integer
    argument. *)

val start_oneshot : t -> int -> (unit -> unit) -> (unit, Error.t) result
(** Like {!Luv.Signal.start}, but the handle is stopped after one callback call.

    Binds
    {{:http://docs.libuv.org/en/v1.x/signal.html#c.uv_signal_start_oneshot}
    [uv_signal_start_oneshot]}. *)

val stop : t -> (unit, Error.t) result
(** Stops the signal handle.

    Binds {{:http://docs.libuv.org/en/v1.x/signal.html#c.uv_signal_stop}
    [uv_signal_stop]}. *)

val signum : t -> int
(** Evaluates to the signal number associated with the handle.

    Binds {{:http://docs.libuv.org/en/v1.x/signal.html#c.uv_signal_t.signum}
    [uv_signal_t.signum]}. *)



(** {1:signals Signal numbers}

    For the moment, the signals exposed are those that are both present on Unix
    and present or emulated by libuv on Windows. See
    {{:http://docs.libuv.org/en/v1.x/signal.html#windows-notes} {i Windows
    notes}} and {{:http://docs.libuv.org/en/v1.x/signal.html#unix-notes} {i Unix
    notes}}.

    Note that these signal numbers do not, in general, match the ones in module
    [Sys] in the OCaml standard library. *)

val sigabrt : int
val sigfpe : int
val sighup : int
val sigill : int
val sigint : int
val sigkill : int
val sigsegv : int
val sigterm : int
val sigwinch : int
