(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let module_doc = {|(** Feature checks.

    If you installed Luv in the usual way, through either opam or esy, you can
    ignore this module completely. In this case, Luv internally installed a
    vendored libuv of a recent version, and you have all the latest APIs
    available — whatever is exposed by your version of Luv {e is} actually
    implemented by libuv.

    However, if you installed Luv through a system package manager, or tweaked
    your Luv installation so that it links to a system or other external libuv,
    that external libuv might be of a considerably older version than Luv. Not
    all features normally exposed by Luv might actually be available.

    In that case, this module provides a bunch of useful feature checks, so that
    you can control the behavior of your downstream project and/or prevent its
    compilation with too old a libuv. *)|}

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

    The compile-time numbers [_0] — [_99] are defined for use in with
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

  let needs min name = bool context name (version >= min) in

  needs  9 "disconnect";
  needs 21 "eftype";
  needs 32 "eilseq";
  needs 16 "enotty";
  needs 22 "err_name_r";
  needs 14 "fs_copyfile";
  needs 20 "fs_copyfile_ficlone";
  needs 36 "fs_lutime";
  needs 21 "fs_lchown";
  needs 34 "fs_mkstemp";
  needs 31 "fs_o_filemap";
  needs  8 "fs_realpath";
  needs 31 "fs_statfs";
  needs 29 "get_constrained_memory";
  needs 12 "get_osfhandle";
  needs 28 "gettimeofday";
  needs 16 "if_indextoiid";
  needs 16 "if_indextoname";
  needs 38 "library_shutdown";
  needs 12 "loop_fork";
  needs 26 "maxhostnamesize";
  needs 39 "metrics_idle_time";
  needs 15 "mutex_init_recursive";
  needs 23 "open_osfhandle";
  needs 31 "os_environ";
  needs  6 "os_homedir";
  needs  9 "os_get_passwd";
  needs 12 "os_getenv";
  needs 12 "os_gethostname";
  needs 18 "os_getpid";
  needs 16 "os_getppid";
  needs 23 "os_priority";
  needs  9 "os_tmpdir";
  needs 25 "os_uname";
  needs 21 "overlapped_pipe";
  needs 16 "pipe_chmod";
  needs 14 "prioritized";
  needs 24 "process_windows_hide_console";
  needs 24 "process_windows_hide_gui";
  needs 33 "random";
  needs 28 "readdir";
  needs 12 "signal_start_oneshot";
  needs 34 "sleep";
  needs 22 "strerror_r";
  needs 32 "tcp_close_reset";
  needs  7 "tcp_init_ex";
  needs 40 "timer_get_due_in";
  needs 26 "thread_stack_size";
  needs 10 "translate_sys_error";
  needs 33 "tty_vterm_state";
  needs 27 "udp_connect";
  needs  7 "udp_init_ex";
  needs 35 "udp_mmsg_chunk";
  needs 40 "udp_mmsg_free";
  needs 37 "udp_recvmmsg";
  needs 32 "udp_set_source_membership";
  needs 39 "udp_using_recvmmsg";

  let mli_channel = open_out mli in
  Buffer.contents mli_buffer |> output_string mli_channel;
  close_out_noerr mli_channel;

  let ml_channel = open_out ml in
  Buffer.contents ml_buffer |> output_string ml_channel;
  close_out_noerr ml_channel
