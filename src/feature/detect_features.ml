(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let module_doc = {|(** Feature checks.

    {e You probably don't need these!}

    If you installed Luv in the usual way, through either opam or esy, you can
    ignore this module completely. In this case, Luv internally installed a
    vendored libuv of a recent version, and you have all the latest APIs
    available — whatever is exposed by your version of Luv {e is} actually
    implemented by libuv.

    However, if you installed Luv through a system package manager, or tweaked
    your Luv installation so that it links to a system or other external libuv
    — or if your users will do so — that external libuv might be of a
    considerably older version than Luv expects. Not all features normally
    exposed by Luv might actually be available.

    For that case, this module provides a bunch of useful feature checks, so
    that you can control the behavior of your downstream project and/or prevent
    its compilation with too old a libuv.

    This module itself is present since Luv 0.5.7. *)|}

let type_feature_doc = {|(** A value of type ['a feature] is physically either a
    [bool] or an [int].

    The [constraint] notation can be ignored. It's part of this module's
    internal type machinery for implementing compile-time feature checking.

    Specific features (see below) have types like [_40 feature] or [_true
    feature]. The first is an [int] feature whose run-time value is [40], and
    the second is a [bool] feature whose run-time value is [true].

    As you can see, the run-time value can be seen from the type, and therefore
    from the docs, at a glance. So, you can quickly find out what your libuv
    supports by generating the docs for your Luv installation and looking at
    this module.

    Of course, if you installed Luv through opam/esy and are using its vendored
    libuv, the [int] features will simply be the corresponding libuv version,
    and all the [bool] features will be [_true]. *)|}

let get_doc = {|(** Returns the value of a feature at run time — in the ordinary
    way. Examples:

    - [Luv.Require.(get luv05)] returns [7] at the time of this writing — the
      current patch version of Luv (0.5.7).
    - [Luv.Require.(get random)] returns [true] if Luv was linked with a libuv
      late enough that it supports [uv_random] (1.33.0 or higher). *)|}

let at_least_doc = {|(** Triggers a compile-time check of an [int] feature.

    For example, take [Luv.Require.(libuv1 >= _33)].

    If the linked libuv has version 1.33.0 or higher, this check compiles. The
    compiled check then does nothing at run time — it is zero-cost.

    If libuv has version less than 1.33.0, compilation of this expression
    triggers a type error. If that is too severe, you can relax to a run-time
    check by doing [Luv.Require.(get libuv1) >= 33] instead.

    The compile-time numbers [_0] — [_99] are defined for use with
    [Luv.Require.(>=)]. They are hidden from this documentation to reduce visual
    noise.

    These compile-time checks are modular in the sense that you can spread them
    throughout your project, locally where various features of libuv are being
    used, so that you don't have to do a survey of all your code in order to
    figure out the overall minimum libuv version. During build, your project
    will compile only if all the checks in its modules pass. They will then be
    optimized away. *)|}

let has_doc = {|(** Triggers a compile-time check of a [bool] feature.

    For example, take [Luv.Require.(has random)].

    If the linked libuv has [uv_random], this check compiles, and is fully
    optimized away.

    If libuv lacks [uv_random], compilation of this check triggers a type error.
    The check can be relaxed to run time by doing [Luv.Require.(get random)]
    instead.

    As with {!Luv.Require.(>=)}, you can insert these checks throughout your
    program, locally near where you use libuv features. The project will compile
    only if all the checks pass. *)|}

let ground_numbers max_int buffer =
  let p fmt = Printf.bprintf buffer fmt in
  p "type 'p s\n";
  p "\n";
  p "type ___0\n";
  for i = 0 to max_int - 1 do
    p "type ___%i = ___%i s\n" (i + 1) i
  done;
  p "type ___inf = ___%i s\n" max_int

let feature_numbers max_int buffer =
  let p fmt = Printf.bprintf buffer fmt in
  for i = 0 to max_int do
    p "type _%i = int * ___%i\n" i i
  done;
  p "type _inf = int * ___inf\n"

let unification_numbers max_int buffer =
  let p fmt = Printf.bprintf buffer fmt in
  p "type 'u __0 = 'u\n";
  for i = 0 to max_int - 1 do
    p "type 'u __%i = 'u __%i s\n" (i + 1) i
  done

(* TODO Allow custom docs at the top of the .mli. *)
(* TODO Docs for the visible values. *)
let fixed_mli max_int buffer =
  let p fmt = Printf.bprintf buffer fmt in
  p "%s\n\n" module_doc;
  p "(**/**)\n";
  p "\n";
  ground_numbers max_int buffer;
  p "\n";
  feature_numbers max_int buffer;
  p "\n";
  unification_numbers max_int buffer;
  p "\n";
  p "type 'compile_time_value number\n";
  p "\n";
  for i = 0 to max_int do
    p "val _%i : 'u __%i number\n" i i
  done;
  p "%s" @@ {|
type __true
type __false

type _true = bool * __true
type _false = bool * __false

(**/**)

type 'a feature
  constraint 'a = 'run_time * 'compile_time
|}^ type_feature_doc ^{|

val get : ('run_time * _) feature -> 'run_time
|}^ get_doc ^{|

val (>=) : (int * 'compile_time) feature -> 'compile_time number -> unit
|}^ at_least_doc ^{|

val has : _true feature -> unit
|}^ has_doc ^{|

(** {1 Features} *)

|}

let fixed_ml max_int buffer =
  let p fmt = Printf.bprintf buffer fmt in
  ground_numbers max_int buffer;
  p "\n";
  feature_numbers max_int buffer;
  p "\n";
  unification_numbers max_int buffer;
  p "\n";
  p "type 'compile_time_value number = unit\n";
  p "\n";
  for i = 0 to max_int do
    p "let _%i = ()\n" i
  done;
    p "%s" {|
type __true
type __false

type _true = bool * __true
type _false = bool * __false

type 'a feature = 'run_time
  constraint 'a = 'run_time * _

let get feature =
  feature

let (>=) _ _ =
  ()

let has _ =
  ()
|}

let wrap_doc doc =
  match doc with
  | "" -> ""
  | _ -> "(** " ^ doc ^ "*)\n"

(* TODO Allow docstrings. *)
let int (mli, ml) ?(doc = "") name value =
  Printf.bprintf mli "\nval %s : _%i feature\n%s" name value (wrap_doc doc);
  Printf.bprintf ml "\nlet %s = %i\n" name value

let bool (mli, ml) ?(doc = "") name value =
  Printf.bprintf mli "\nval %s : _%b feature\n%s" name value (wrap_doc doc);
  Printf.bprintf ml "\nlet %s = %b\n" name value

let () =
  let mli = Sys.argv.(1) ^ "i" in
  let ml = Sys.argv.(1) in
  let max_int = int_of_string Sys.argv.(2) in

  let mli_buffer = Buffer.create 4096 in
  fixed_mli max_int mli_buffer;

  let ml_buffer = Buffer.create 4096 in
  fixed_ml max_int ml_buffer;

  let version = Luv_c_types.Version.minor in

  let context = mli_buffer, ml_buffer in
  let int = int context in

  int "libuv1" version ~doc:"libuv minor version in the 1.x series.";
  int "luv05" 7 ~doc:"Luv patch version in the 0.5.x series.";

  let needs min name doc =
    let doc = Printf.sprintf "%s Requires libuv 1.%i.0." doc min in
    bool context ~doc name (version >= min)
  in

  let parallelism = "available_parallelism" in
  needs 44 parallelism "See {!Luv.System_info.available_parallelism}.";
  needs 45 "clock_gettime" "See {!Luv.Time.clock_gettime}.";
  needs 45 "cpumask_size" "See {!Luv.System_info.cpumask_size}.";
  needs  9 "disconnect" "See [`DISCONNECT] in {!Luv.Poll.Event.t}.";
  needs 21 "eftype" "See [`EFTYPE] in {!Luv.Error.t}.";
  needs 32 "eilseq" "See [`EILSEQ] in {!Luv.Error.t}.";
  needs 16 "enotty" "See [`ENOTTY] in {!Luv.Error.t}.";
  needs 42 "eoverflow" "See [`EOVERFLOW] in {!Luv.Error.t}.";
  needs 42 "esocktnosupport" "See [`ESOCKTNOSUPPORT] in {!Luv.Error.t}.";
  needs 22 "err_name_r" "See {!Luv.Error.err_name}.";
  needs 14 "fs_copyfile" "See {!Luv.File.copyfile}.";
  needs 20 "fs_copyfile_ficlone" "See signature of {!Luv.File.copyfile}.";
  needs 36 "fs_lutime" "See {!Luv.File.lutime}.";
  needs 21 "fs_lchown" "See {!Luv.File.lchown}.";
  needs 34 "fs_mkstemp" "See {!Luv.File.mkstemp}.";
  needs 31 "fs_o_filemap" "See [`FILEMAP] {!Luv.File.Open_flag.t}.";
  needs  8 "fs_realpath" "See {!Luv.File.realpath}.";
  needs 31 "fs_statfs" "See {!Luv.File.statfs}.";
  needs 45 "get_available_memory" "See {!Luv.Resource.available_memory}.";
  needs 29 "get_constrained_memory" "See {!Luv.Resource.constrained_memory}.";
  needs 12 "get_osfhandle" "See {!Luv.File.get_osfhandle}.";
  needs 45 "getaffinity" "See {!Luv.Thread.getaffinity}";
  needs 45 "getcpu" "See {!Luv.Thread.getcpu}.";
  needs 28 "gettimeofday" "See {!Luv.Time.gettimeofday}.";
  needs 16 "if_indextoiid" "See {!Luv.Network.if_indextoiid}.";
  needs 16 "if_indextoname" "See {!Luv.Network.if_indextoname}.";
  needs 38 "library_shutdown" "See {!Luv.Loop.library_shutdown}.";
  needs 12 "loop_fork" "See {!Luv.Loop.fork}.";
  needs 26 "maxhostnamesize" "Used internally.";
  needs 39 "metrics_idle_time" "See {!Luv.Metrics.idle_time}.";
  needs 45 "metrics_info" "See {!Luv.Metrics.info}.";
  needs 15 "mutex_init_recursive" "See {!Luv.Mutex.init}.";
  needs 23 "open_osfhandle" "See {!Luv.File.open_osfhandle}.";
  needs 31 "os_environ" "See {!Luv.Env.environ}.";
  needs  6 "os_homedir" "See {!Luv.Path.homedir}.";
  needs 45 "os_get_group" "See {!Luv.Passwd.get_group}.";
  needs  9 "os_get_passwd" "See {!Luv.Passwd.get_passwd}.";
  needs 45 "os_get_passwd_uid" "See {!Luv.Passwd.get_passwd}.";
  needs 12 "os_getenv" "See {!Luv.Env.getenv}.";
  needs 12 "os_gethostname" "See {!Luv.Network.gethostname}.";
  needs 18 "os_getpid" "See {!Luv.Pid.getpid}.";
  needs 16 "os_getppid" "See {!Luv.Pid.getppid}.";
  needs 23 "os_priority" "See {!Luv.Resource.setpriority}.";
  needs  9 "os_tmpdir" "See {!Luv.Path.tmpdir}.";
  needs 25 "os_uname" "See {!Luv.System_info.uname}.";
  needs 21 "overlapped_pipe" "See {!Luv.Process.to_parent_pipe}.";
  needs 41 "pipe" "See {!Luv.Pipe.pipe}";
  needs 46 "pipe_bind2" "See {!Luv.Pipe.bind}.";
  needs 46 "pipe_connect2" "See {!Luv.Pipe.connect}.";
  needs 16 "pipe_chmod" "See {!Luv.Pipe.chmod}.";
  needs 14 "prioritized" "See [`PRIORITIZED] in {!Luv.Poll.Event.t}.";
  needs 24 "process_windows_hide_console" "See {!Luv.Process.spawn}.";
  needs 24 "process_windows_hide_gui" "See {!Luv.Process.spawn}.";
  needs 33 "random" "See {!Luv.Random.random}.";
  needs 28 "readdir" "See {!Luv.File.readdir}.";
  needs 45 "setaffinity" "See {!Luv.Thread.setaffinity}";
  needs 12 "signal_start_oneshot" "See {!Luv.Signal.start_oneshot}.";
  needs 34 "sleep" "See {!Luv.Time.sleep}.";
  needs 41 "socketpair" "See {!Luv.TCP.socketpair}.";
  needs 22 "strerror_r" "See {!Luv.Error.strerror}.";
  needs 32 "tcp_close_reset" "See {!Luv.TCP.close_reset}.";
  needs  7 "tcp_init_ex" "See {!Luv.TCP.init}.";
  needs 40 "timer_get_due_in" "See {!Luv.Timer.get_due_in}.";
  needs 26 "thread_stack_size" "See {!Luv.Thread.create}.";
  needs 10 "translate_sys_error" "See {!Luv.Error.translate_sys_error}.";
  needs 42 "try_write2" "See {!Luv.Stream.try_write2}.";
  needs 33 "tty_vterm_state" "See {!Luv.TTY.set_vterm_state}.";
  needs 27 "udp_connect" "See {!Luv.UDP.Connected}.";
  needs  7 "udp_init_ex" "See {!Luv.UDP.init}.";
  needs 35 "udp_mmsg_chunk" "See [`MMSG_CHUNK] in {!Luv.UDP.Recv_flag.t}.";
  needs 40 "udp_mmsg_free" "See [`MMSG_FREE] in {!Luv.UDP.Recv_flag.t}.";
  needs 37 "udp_recvmmsg" "See {!Luv.UDP.init}.";
  needs 32 "udp_set_source_membership" "See {!Luv.UDP.set_source_membership}.";
  needs 39 "udp_using_recvmmsg" "See {!Luv.UDP.using_recvmmsg}.";
  needs 47 "utf_16" "See {!Luv.String}.";

  let mli_channel = open_out mli in
  Buffer.contents mli_buffer |> output_string mli_channel;
  close_out_noerr mli_channel;

  let ml_channel = open_out ml in
  Buffer.contents ml_buffer |> output_string ml_channel;
  close_out_noerr ml_channel
