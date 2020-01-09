(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(* DOC About the libuv mess w.r.t. fd types. *)
(* DOC Link to where the various helpers working on these can be found. *)
module Os_fd :
sig
  type t = C.Types.Os_fd.t
  (* DOC This fails on Windows sockets. *)
  val from_unix : Unix.file_descr -> (t, Error.t) Result.result
  val to_unix : t -> Unix.file_descr
end

module Os_socket :
sig
  type t = C.Types.Os_socket.t
  (* DOC This fails on Windows HANDLEs, probably a complement of
     Os_fd.from_unix. *)
  val from_unix : Unix.file_descr -> (t, Error.t) Result.result
  val to_unix : t -> Unix.file_descr
end

(* TODO Check pid_t, uid_t, gid_t, ... *)

module Address_family :
sig
  type t = private int

  val unspec : t
  val inet : t
  val inet6 : t

  (**/**)

  val custom : int -> t
end

module Socket_type :
sig
  type t = private int

  val stream : t
  val dgram : t

  (**/**)

  val custom : int -> t
end

module Sockaddr :
sig
  type t

  val ipv4 : string -> int -> (t, Error.t) Result.result
  val ipv6 : string -> int -> (t, Error.t) Result.result

  val to_string : t -> string
  val port : t -> int

  (**/**)

  val copy_storage : C.Types.Sockaddr.storage Ctypes.ptr -> t
  val copy_sockaddr : C.Types.Sockaddr.t Ctypes.ptr -> int -> t

  val as_sockaddr : t -> C.Types.Sockaddr.t Ctypes.ptr
  val null : C.Types.Sockaddr.t Ctypes.ptr

  val wrap_c_getter :
    ('handle -> C.Types.Sockaddr.t Ctypes.ptr -> int Ctypes.ptr -> Error.t) ->
    ('handle -> (t, Error.t) Result.result)
end

module Resource :
sig
  val uptime : unit -> (float, Error.t) Result.result
  val loadavg : unit -> float * float * float
  val free_memory : unit -> Unsigned.uint64
  val total_memory : unit -> Unsigned.uint64
  val constrained_memory : unit -> Unsigned.uint64 option
  val getpriority : int -> (int, Error.t) Result.result
  val setpriority : int -> int -> Error.t
  val resident_set_memory_size :
    unit -> (Unsigned.size_t, Error.t) Result.result

  type timeval = {
    sec : Signed.Long.t;
    usec : Signed.Long.t;
  }

  type rusage = {
    utime : timeval;
    stime : timeval;
    maxrss : Unsigned.uint64;
    ixrss : Unsigned.uint64;
    idrss : Unsigned.uint64;
    isrss : Unsigned.uint64;
    minflt : Unsigned.uint64;
    majflt : Unsigned.uint64;
    nswap : Unsigned.uint64;
    inblock : Unsigned.uint64;
    oublock : Unsigned.uint64;
    msgsnd : Unsigned.uint64;
    msgrcv : Unsigned.uint64;
    nsignals : Unsigned.uint64;
    nvcsw : Unsigned.uint64;
    nivcsw : Unsigned.uint64;
  }

  val rusage : unit -> (rusage, Error.t) Result.result
end

(* TODO Support OS pids. *)
module Pid :
sig
  val getpid : unit -> int
  val getppid : unit -> int
end

module CPU_info :
sig
  type times = {
    user : Unsigned.uint64;
    nice : Unsigned.uint64;
    sys : Unsigned.uint64;
    idle : Unsigned.uint64;
    irq : Unsigned.uint64;
  }

  type t = {
    model : string;
    speed : int;
    times : times;
  }

  val get : unit -> (t list, Error.t) Result.result
end

module Network :
sig
  val if_indextoname : int -> (string, Error.t) Result.result
  val if_indextoiid : int -> (string, Error.t) Result.result
  val gethostname : unit -> (string, Error.t) Result.result
end

module Path :
sig
  val exepath : unit -> (string, Error.t) Result.result
  val cwd : unit -> (string, Error.t) Result.result
  val chdir : string -> Error.t
  val homedir : unit -> (string, Error.t) Result.result
  val tmpdir : unit -> (string, Error.t) Result.result
end

module Passwd :
sig
  type t = {
    username : string;
    uid : int;
    gid : int;
    shell : string option;
    homedir : string;
  }

  val get : unit -> (t, Error.t) Result.result
end

module Hrtime :
sig
  val now : unit -> Unsigned.uint64
end

module Env :
sig
  val getenv : string -> (string, Error.t) Result.result
  val setenv : string -> string -> Error.t
  val unsetenv : string -> Error.t
  val environ : unit -> ((string * string) list, Error.t) Result.result
end

module System_name :
sig
  type t = {
    sysname : string;
    release : string;
    version : string;
    machine : string;
  }

  val uname : unit -> (t, Error.t) Result.result
end

module Time :
sig
  type t = {
    tv_sec : int64;
    tv_usec : int32;
  }

  val gettimeofday : unit -> (t, Error.t) Result.result
end

module Random :
sig
  module Async :
  sig
    val random : ?loop:Loop.t -> Bigstring.t -> (Error.t -> unit) -> unit
  end

  module Sync :
  sig
    val random : Bigstring.t -> Error.t
  end
end

module Sleep :
sig
  val sleep : int -> unit
end
