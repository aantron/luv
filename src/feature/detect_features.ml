(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let ground_numbers max_int buffer =
  let p fmt = Printf.bprintf buffer fmt in
  p "type 'p s\n";
  p "\n";
  p "type __0\n";
  for i = 0 to max_int - 1 do
    p "type __%i = __%i s\n" (i + 1) i
  done;
  p "type __inf = __%i\n" max_int

let unification_numbers max_int buffer =
  let p fmt = Printf.bprintf buffer fmt in
  p "type 'u _0 = 'u\n";
  for i = 0 to max_int - 1 do
    p "type 'u _%i = 'u _%i s\n" (i + 1) i
  done

(* TODO Allow custom docs at the top of the .mli. *)
(* TODO Docs for the visible values. *)
let fixed_mli max_int buffer =
  let p fmt = Printf.bprintf buffer fmt in
  p "(**/*)\n";
  p "\n";
  ground_numbers max_int buffer;
  p "\n";
  unification_numbers max_int buffer;
  p "\n";
  p "type 'compile_time_value number\n";
  p "\n";
  for i = 0 to max_int do
    p "val _%i : 'u _%i number\n" i i
  done;
  p "%s" {|
type _true
type _false

(**/*)

type ('run_time_value, 'compile_time_value) feature

val run_time_check : ('run_time_value, _) feature -> 'run_time_value

val at_least :
  (_, 'compile_time_value) feature -> 'compile_time_value number -> unit
val (>=) :
  (_, 'compile_time_value) feature -> 'compile_time_value number -> unit
val present :
  (_, _true) feature -> unit
|}

let fixed_ml max_int buffer =
  let p fmt = Printf.bprintf buffer fmt in
  ground_numbers max_int buffer;
  p "\n";
  unification_numbers max_int buffer;
  p "\n";
  p "type 'compile_time_value number = unit\n";
  p "\n";
  for i = 0 to max_int do
    p "let _%i = ()\n" i
  done;
    p "%s" {|
type _true
type _false

type ('run_time_value, 'compile_time_value) feature = 'run_time_value

let run_time_check feature =
  feature

let at_least _ _ =
  ()

let (>=) _ _ =
  ()

let present _ =
  ()
|}

(* TODO Allow docstrings. *)
let int (mli, ml) name value =
  Printf.bprintf mli "\nval %s : (int, __%i) feature\n" name value;
  Printf.bprintf ml "\nlet %s = %i\n" name value

let bool (mli, ml) name value =
  Printf.bprintf mli "\nval %s : (bool, _%b) feature\n" name value;
  Printf.bprintf ml "\nlet %s = %b\n" name value

let () =
  let mli = "feature.mli" in
  let ml = "feature.ml" in
  let max_int = 99 in

  let mli_buffer = Buffer.create 4096 in
  fixed_mli max_int mli_buffer;

  let ml_buffer = Buffer.create 4096 in
  fixed_ml max_int ml_buffer;

  let context = mli_buffer, ml_buffer in
  let int = int context in
  let bool = bool context in

  let version = Luv_c_types.Version.minor in

  int "libuv1" version;
  int "luv05" 7;

  bool "udp_mmsg_free" (version >= 40);
  bool "timer_get_due_in" (version >= 40);

  bool "metrics_idle_time" (version >= 39);
  bool "udp_using_recvmmsg" (version >= 39);

  bool "library_shutdown" (version >= 38);

  bool "udp_recvmmsg" (version >= 37);

  bool "fs_lutime" (version >= 36);

  bool "udp_mmsg_chunk" (version >= 35);

  bool "fs_mkstemp" (version >= 34);
  bool "sleep" (version >= 34);

  bool "random" (version >= 33);
  bool "tty_vterm_state" (version >= 33);

  bool "eilseq" (version >= 32);
  bool "tcp_close_reset" (version >= 32);
  bool "udp_set_source_membership" (version >= 32);

  bool "fs_o_filemap" (version >= 31);
  bool "fs_statfs" (version >= 31);
  bool "os_environ" (version >= 31);

  bool "get_constrained_memory" (version >= 29);

  bool "gettimeofday" (version >= 28);
  bool "readdir" (version >= 28);

  bool "udp_connect" (version >= 27);

  bool "thread_stack_size" (version >= 26);
  bool "maxhostnamesize" (version >= 26);

  let mli_channel = open_out mli in
  Buffer.contents mli_buffer |> output_string mli_channel;
  close_out_noerr mli_channel;

  let ml_channel = open_out ml in
  Buffer.contents ml_buffer |> output_string ml_channel;
  close_out_noerr ml_channel
