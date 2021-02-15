(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Subprocesses.

    See {{:https://aantron.github.io/luv/processes.html} {i Processes}} in the
    user guide and {{:http://docs.libuv.org/en/v1.x/process.html} [uv_process_t]
    {i — Process handle}} in libuv. *)

type t = [ `Process ] Handle.t
(** Binds {{:http://docs.libuv.org/en/v1.x/process.html#c.uv_process_t}
    [uv_process_t]}.

    Note that values of this type can be passed to functions in {!Luv.Handle},
    in addition to the functions in this module. In particular, see
    {!Luv.Handle.close}. *)

type redirection
(** File descriptor redirections for use with {!Luv.Process.spawn}. *)

val to_parent_pipe :
  ?readable_in_child:bool ->
  ?writable_in_child:bool ->
  ?overlapped:bool ->
  fd:int ->
  parent_pipe:Pipe.t ->
  unit ->
    redirection
(** Causes [~fd] in the child to be connected to [~to_parent_pipe] in the
    parent.

    Binds {{:http://docs.libuv.org/en/v1.x/process.html#c.uv_stdio_flags}
    [UV_CREATE_PIPE]}.

    [?readable_in_child] sets
    {{:http://docs.libuv.org/en/v1.x/process.html#c.uv_stdio_flags}
    [UV_READABLE_PIPE]}, and [?writable_in_child] sets
    {{:http://docs.libuv.org/en/v1.x/process.html#c.uv_stdio_flags}
    [UV_WRITABLE_PIPE]}.

    [?overlapped] sets
    {{:http://docs.libuv.org/en/v1.x/process.html#c.uv_stdio_flags}
    [UV_OVERLAPPED_PIPE]}. This requires libuv 1.21.0. On earlier versions, the
    optional argument does nothing.

    {{!Luv.Require} Feature check}: [Luv.Require.(has overlapped_pipe)] *)

val inherit_fd :
  fd:int ->
  from_parent_fd:int ->
  unit ->
    redirection
(** Causes [~fd] in the child to be connected to the same device or peer as
    [~from_parent_fd] in the parent.

    Binds {{:http://docs.libuv.org/en/v1.x/process.html#c.uv_stdio_flags}
    [UV_INHERIT_FD]}. *)

val inherit_stream :
  fd:int ->
  from_parent_stream:_ Stream.t ->
  unit ->
    redirection
(** Same as {!Luv.Process.inherit_fd}, but takes a {!Luv.Stream.t} for the
    parent file descriptor.

    Binds {{:http://docs.libuv.org/en/v1.x/process.html#c.uv_stdio_flags}
    [UV_INHERIT_STREAM]}. *)

val stdin : int
val stdout : int
val stderr : int

val spawn :
  ?loop:Loop.t ->
  ?on_exit:(t -> exit_status:int64 -> term_signal:int -> unit) ->
  ?environment:(string * string) list ->
  ?working_directory:string ->
  ?redirect:redirection list ->
  ?uid:int ->
  ?gid:int ->
  ?windows_verbatim_arguments:bool ->
  ?detached:bool ->
  ?windows_hide:bool ->
  ?windows_hide_console:bool ->
  ?windows_hide_gui:bool ->
  string ->
  string list ->
    (t, Error.t) result
(** Starts a process.

    Binds {{:http://docs.libuv.org/en/v1.x/process.html#c.uv_spawn} [uv_spawn]}.

    Most of the optional arguments correspond to the fields of
    {{:http://docs.libuv.org/en/v1.x/process.html#c.uv_process_options_t}
    [uv_process_options_t]}, which are documented
    {{:http://docs.libuv.org/en/v1.x/process.html#public-members} here}. The
    remaining arguments correspond to flags from
    {{:http://docs.libuv.org/en/v1.x/process.html#c.uv_process_flags}
    [uv_process_flags]}.

    On Unix, the [~term_signal] argument to [?on_exit] will be non-zero if the
    process was terminated by a signal. In this case, the [~exit_status] is
    invalid.

    On Windows, [~term_signal] and [~exit_status] are independent of each other.
    [~term_signal] is set by {!Luv.Process.kill}, i.e. it is emulated by libuv.
    The operating system separately reports [~exit_status], so it is always
    valid. If there is an error retrieving [~exit_status] from the OS, it is set
    to a negative value.

    Redirections for STDIN, STDOUT, STDERR that are not specified are set by Luv
    to [UV_IGNORE]. This causes libuv to open new file descriptors for the child
    process, and redirect them to [/dev/null] or [nul].

    [?windows_hide_console] and [?windows_hide_gui] have no effect on libuv
    prior to 1.24.0.

    {{!Luv.Require} Feature checks}:

    - [Luv.Require.(has process_windows_hide_console)]
    - [Luv.Require.(has process_windows_hide_gui)] *)

val disable_stdio_inheritance : unit -> unit
(** Disables (tries) file descriptor inheritance for inherited descriptors.

    Binds
    {{:http://docs.libuv.org/en/v1.x/process.html#c.uv_disable_stdio_inheritance}
    [uv_disable_stdio_inheritance]}. *)

val kill : t -> int -> (unit, Error.t) result
(** Sends the given signal to the process.

    Binds {{:http://docs.libuv.org/en/v1.x/process.html#c.uv_process_kill}
    [uv_process_kill]}. See
    {{:http://man7.org/linux/man-pages/man3/kill.3p.html} [kill(3p)]}.

    See {!Luv.Signal} for signal numbers. *)

val kill_pid : pid:int -> int -> (unit, Error.t) result
(** Sends the given signal to the process with the given pid.

    Binds {{:http://docs.libuv.org/en/v1.x/process.html#c.uv_kill} [uv_kill]}.

    See {!Luv.Signal} for signal numbers. *)

val pid : t -> int
(** Evaluates to the pid of the process.

    Binds {{:http://docs.libuv.org/en/v1.x/process.html#c.uv_process_get_pid}
    [uv_process_get_pid]}. *)
