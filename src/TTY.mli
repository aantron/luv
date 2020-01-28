(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Consoles.

    See {{:http://docs.libuv.org/en/v1.x/tty.html} [uv_tty_t] {i — TTY
    handle}} in libuv. *)

type t = [ `TTY ] Stream.t
(** Binds {{:http://docs.libuv.org/en/v1.x/tty.html#c.uv_tty_t}}.

    Note that values of this type can also be used with functions in:

    - {!Luv.Stream}
    - {!Luv.Handle}

    In particular, see {!Luv.Handle.close}, {!Luv.Stream.read_start}, and
    {!Luv.Stream.write}. *)

val init : ?loop:Loop.t -> File.t -> (t, Error.t) result
(** Allocates and initializes a TTY handle.

    Binds {{:http://docs.libuv.org/en/v1.x/tty.html#c.uv_tty_init}
    [uv_tty_init]}. *)

(** Binds {{:http://docs.libuv.org/en/v1.x/tty.html#c.uv_tty_mode_t}
    [uv_tty_mode_t]}. *)
module Mode :
sig
  type t = [
    | `NORMAL
    | `RAW
    | `IO
  ]
end

val set_mode : t -> Mode.t -> (unit, Error.t) result
(** Sets the TTY's mode.

    Binds {{:http://docs.libuv.org/en/v1.x/tty.html#c.uv_tty_set_mode}
    [uv_tty_set_mode]}. *)

val reset_mode : unit -> (unit, Error.t) result
(** Resets the TTY's mode.

    Binds {{:http://docs.libuv.org/en/v1.x/tty.html#c.uv_tty_reset_mode}
    [uv_tty_reset_mode]}. *)

val get_winsize : t -> (int * int, Error.t) result
(** Retrieves the current window size.

    Binds {{:http://docs.libuv.org/en/v1.x/tty.html#c.uv_tty_get_winsize}
    [uv_tty_get_winsize]}. *)

(** Binds {{:http://docs.libuv.org/en/v1.x/tty.html#c.uv_tty_vtermstate_t}
    [uv_tty_vtermstate_t]}. *)
module Vterm_state :
sig
  type t = [
    | `SUPPORTED
    | `UNSUPPORTED
  ]
end

val set_vterm_state : Vterm_state.t -> unit
(** Binds {{:http://docs.libuv.org/en/v1.x/tty.html#c.uv_tty_set_vterm_state}
    [uv_tty_set_vterm_state]}. *)

val get_vterm_state : unit -> (Vterm_state.t, Error.t) result
(** Binds {{:http://docs.libuv.org/en/v1.x/tty.html#c.uv_tty_get_vterm_state}
    [uv_tty_get_vterm_state]}. *)
