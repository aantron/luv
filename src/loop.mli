(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Event loops. See {{:http://docs.libuv.org/en/v1.x/loop.html} [uv_loop_t]} in
    the libuv documentation.

    libuv event loops process I/O and call callbacks. A typical Luv application
    uses one loop:

    {[
      let () =
        print_endline "Running forever. Press Ctrl+C to exit.";
        Luv.Loop.run ()
    ]}

    Once {!Luv.Loop.run} is called, the process runs forever, until
    {!Luv.Loop.stop} is called, or the process terminates in some other way,
    such as by calling
    {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Stdlib.html#VALexit}
    [exit]}.

    See the example in module {!Luv.Timer} for an example that actually calls an
    interesting callback. *)
(* TODO Fix the example. *)

type t = C.Types.Loop.t Ctypes.ptr
(** Event loops. Binding to
    {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_loop_t} [uv_loop_t]}. *)
(* TODO DOC Make the type abstract in the rendered docs. *)

module Run_mode :
sig
  type t = [
    | `DEFAULT
    | `ONCE
    | `NOWAIT
  ]
end
(* TODO Inline Run_mode body. *)

(* TODO Sections? *)

val run : ?loop:t -> ?mode:Run_mode.t -> unit -> bool
(** Runs an event loop. See {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_run}
    [uv_run]}.

    If [~loop] is specified, the given loop will be run. If not, this function
    will run [Luv.Loop.default ()], which is suitable for most cases.

    See {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_run} [uv_run]} for the
    meaning of the constants that can be specified with [~mode]. If not
    specified, it is equivalent to [~mode:Luv.Loop.Run_mode.default], which runs
    the loop indefinitely, until {!Luv.Loop.stop} is called.

    This function typically should not be called by a library based on Luv.
    Rather, it should be called by applications. *)

val default : unit -> t
(** Returns the default event loop. See
    {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_default_loop}
    [uv_default_loop]}. *)

val init : unit -> (t, Error.t) Result.result
(** Creates a new event loop. See
    {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_loop_init}
    [uv_loop_init]}. *)

val close : t -> (unit, Error.t) Result.result
(** Releases resources associated with an event loop. See
    {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_loop_close}
    [uv_loop_close]}. *)

val now : t -> Unsigned.UInt64.t
(** Returns the cached loop timestamp. See
    {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_now} [uv_now]}. *)

val update_time : t -> unit
(** Update the cached loop timestamp. See
    {{:http://docs.libuv.org/en/v1.x/loop.html#c.uv_update_time}
    [uv_update_time]}. *)

module Option :
sig
  type 'value t
  val block_signal : int t
  val sigprof : int
end
(* TODO Make the signum type abstract. *)

val configure : t -> 'value Option.t -> 'value -> (unit, Error.t) Result.result

val alive : t -> bool
val stop : t -> unit
val size : unit -> Unsigned.size_t
val backend_fd : t -> int
val backend_timeout : t -> int

val fork : t -> (unit, Error.t) Result.result

(**/**)

val get_data : t -> unit Ctypes.ptr
val set_data : t -> unit Ctypes.ptr -> unit
val or_default : t option -> t
