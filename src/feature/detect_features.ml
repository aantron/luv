(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



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
  p "%s" {|
type __true
type __false

type _true = bool * __true
type _false = bool * __false

(**/**)

type 'a feature
  constraint 'a = 'run_time * 'compile_time

val get : ('run_time * _) feature -> 'run_time

val (>=) : (int * 'compile_time) feature -> 'compile_time number -> unit
val has : _true feature -> unit
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

(* TODO Allow docstrings. *)
let int (mli, ml) name value =
  Printf.bprintf mli "\nval %s : _%i feature\n" name value;
  Printf.bprintf ml "\nlet %s = %i\n" name value

let bool (mli, ml) name value =
  Printf.bprintf mli "\nval %s : _%b feature\n" name value;
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

  int "libuv1" version;
  int "luv05" 7;

  let needs min name = bool context name (version >= min) in

  needs 40 "udp_mmsg_free";
  needs 40 "timer_get_due_in";

  needs 39 "metrics_idle_time";
  needs 39 "udp_using_recvmmsg";

  needs 38 "library_shutdown";

  needs 37 "udp_recvmmsg";

  needs 36 "fs_lutime";

  needs 35 "udp_mmsg_chunk";

  needs 34 "fs_mkstemp";
  needs 34 "sleep";

  needs 33 "random";
  needs 33 "tty_vterm_state";

  needs 32 "eilseq";
  needs 32 "tcp_close_reset";
  needs 32 "udp_set_source_membership";

  needs 31 "fs_o_filemap";
  needs 31 "fs_statfs";
  needs 31 "os_environ";

  needs 29 "get_constrained_memory";

  needs 28 "gettimeofday";
  needs 28 "readdir";

  needs 27 "udp_connect";

  needs 26 "thread_stack_size";
  needs 26 "maxhostnamesize";

  needs 25 "os_uname";

  needs 24 "process_windows_hide_console";
  needs 24 "process_windows_hide_gui";

  needs 23 "open_osfhandle";
  needs 23 "uv_os_priority";

  needs 22 "strerror_r";
  needs 22 "err_name_r";

  needs 21 "eftype";
  needs 21 "overlapped_pipe";
  needs 21 "fs_lchown";

  needs 20 "fs_copyfile_ficlone";

  needs 18 "os_getpid";

  needs 16 "enotty";
  needs 16 "pipe_chmod";
  needs 16 "os_getppid";
  needs 16 "if_indextoname";
  needs 16 "if_indextoiid";

  needs 15 "mutex_init_recursive";

  needs 14 "prioritized";
  needs 14 "fs_copyfile";

  needs 12 "loop_fork";
  needs 12 "signal_start_oneshot";
  needs 12 "get_osfhandle";
  needs 12 "os_getenv";
  needs 12 "os_gethostname";

  needs 10 "translate_sys_error";

  needs  9 "disconnect";
  needs  9 "os_tmpdir";
  needs  9 "os_get_passwd";

  needs  8 "fs_realpath";

  needs  7 "tcp_init_ex";
  needs  7 "udp_init_ex";

  needs  6 "os_homedir";

  let mli_channel = open_out mli in
  Buffer.contents mli_buffer |> output_string mli_channel;
  close_out_noerr mli_channel;

  let ml_channel = open_out ml in
  Buffer.contents ml_buffer |> output_string ml_channel;
  close_out_noerr ml_channel
