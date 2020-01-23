(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Os_fd :
sig
  type t = C.Types.Os_fd.t
  (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_fd_t}}. *)

  val from_unix : Unix.file_descr -> (t, Error.t) result
  (** Attempts to convert from a
      {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Unix.html#TYPEfile_descr}
      [Unix.file_descr]} to a libuv [uv_os_fd_t].

      Fails on Windows if the descriptor is a [SOCKET] rather than a
      [HANDLE]. *)

  val to_unix : t -> Unix.file_descr
  (** Converts a [uv_os_fd_t] to a
      {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Unix.html#TYPEfile_descr}
      [Unix.file_descr]}. *)
end

module Os_socket :
sig
  type t = C.Types.Os_socket.t
  (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_sock_t}}. *)

  val from_unix : Unix.file_descr -> (t, Error.t) result
  (** Attempts to convert from a
      {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Unix.html#TYPEfile_descr}
      [Unix.file_descr]} to a libuv [uv_os_sock_t].

      Fails on Windows if the descriptor is a [HANDLE] rather than a
      [SOCKET]. *)

  val to_unix : t -> Unix.file_descr
  (** Converts a [uv_os_sock_t] to a
      {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Unix.html#TYPEfile_descr}
      [Unix.file_descr]}. *)
end

(** Network address families. See
    {{:http://man7.org/linux/man-pages/man2/socket.2.html#DESCRIPTION}
    [socket(2)]}. *)
module Address_family :
sig
  type t = [
    | `UNSPEC
    | `INET
    | `INET6
    | `OTHER of int
  ]

  (**/**)

  val to_c : t -> int
  val from_c : int -> t
end

(** Socket types. See
    {{:http://man7.org/linux/man-pages/man2/socket.2.html#DESCRIPTION}
    [socket(2)]}. *)
module Socket_type :
sig
  type t = [
    | `STREAM
    | `DGRAM
    | `RAW
  ]

  (**/**)

  val to_c : t -> int
  val from_c : int -> t
end

module Sockaddr :
sig
  type t
  (** Binds {{:http://man7.org/linux/man-pages/man7/ip.7.html#DESCRIPTION}
      [struct sockaddr]}.

      The functions in this module automatically take care of converting between
      network and host byte order. *)

  val ipv4 : string -> int -> (t, Error.t) result
  (** Converts a string and port number to an IPv4 [struct sockaddr].

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_ip4_addr}
      [uv_ip4_addr]}. *)

  val ipv6 : string -> int -> (t, Error.t) result
  (** Converts a string and port number to an IPv6 [struct sockaddr].

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_ip6_addr}
      [uv_ip4_addr]}. *)

  val to_string : t -> string option
  (** Converts a network address to a string.

      Binds either {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_ip4_name}
      [uv_ip4_name]} and
      {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_ip6_name}
      [uv_ip6_name]}. *)

  val port : t -> int option
  (** Extracts the port in a network address. *)

  (**/**)

  val copy_storage : C.Types.Sockaddr.storage Ctypes.ptr -> t
  val copy_sockaddr : C.Types.Sockaddr.t Ctypes.ptr -> int -> t

  val as_sockaddr : t -> C.Types.Sockaddr.t Ctypes.ptr
  val null : C.Types.Sockaddr.t Ctypes.ptr

  val wrap_c_getter :
    ('handle -> C.Types.Sockaddr.t Ctypes.ptr -> int Ctypes.ptr -> int) ->
    ('handle -> (t, Error.t) result)
end

module Resource :
sig
  val uptime : unit -> (float, Error.t) result
  (** Evaluates to the current uptime.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_uptime}
      [uv_uptime]}. *)

  val loadavg : unit -> float * float * float
  (** Evaluates to the load average.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_loadavg}
      [uv_loadavg]}. *)

  val free_memory : unit -> Unsigned.uint64
  (** Evaluates to the amount of free memory, in bytes.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_get_free_memory}
      [uv_get_free_memory]}. *)

  val total_memory : unit -> Unsigned.uint64
  (** Evaluates to the total amount of memory, in bytes.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_get_total_memory}
      [uv_get_total_memory]}. *)

  val constrained_memory : unit -> Unsigned.uint64 option
  (** Binds
      {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_get_constrained_memory}}. *)

  val getpriority : int -> (int, Error.t) result
  (** Evaluates to the priority of the process with the given pid.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_getpriority}
      [uv_os_getpriority]}. *)

  val setpriority : int -> int -> (unit, Error.t) result
  (** Sets the priority of the process with the given pid.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_setpriority}
      [uv_os_setpriority]}. *)

  val resident_set_memory : unit -> (Unsigned.size_t, Error.t) result
  (** Evaluates to the resident set size for the current process.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_resident_set_memory}
      [uv_resident_set_memory]}. *)

  type timeval = {
    sec : Signed.Long.t;
    usec : Signed.Long.t;
  }
  (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_timeval_t}
      [uv_timeval_t]}. *)

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
  (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_rusage_t}
      [uv_rusage_t]}.

      See {{:http://man7.org/linux/man-pages/man2/getrusage.2.html#DESCRIPTION}
      [getrusage(2)]}. *)

  val rusage : unit -> (rusage, Error.t) result
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

  val get : unit -> (t list, Error.t) result
end

module Network :
sig
  val if_indextoname : int -> (string, Error.t) result
  val if_indextoiid : int -> (string, Error.t) result
  val gethostname : unit -> (string, Error.t) result
end

module Path :
sig
  val exepath : unit -> (string, Error.t) result
  val cwd : unit -> (string, Error.t) result
  val chdir : string -> (unit, Error.t) result
  val homedir : unit -> (string, Error.t) result
  val tmpdir : unit -> (string, Error.t) result
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

  val get : unit -> (t, Error.t) result
end

module Hrtime :
sig
  val now : unit -> Unsigned.uint64
end

module Env :
sig
  val getenv : string -> (string, Error.t) result
  val setenv : string -> string -> (unit, Error.t) result
  val unsetenv : string -> (unit, Error.t) result
  val environ : unit -> ((string * string) list, Error.t) result
end

module System_name :
sig
  type t = {
    sysname : string;
    release : string;
    version : string;
    machine : string;
  }

  val uname : unit -> (t, Error.t) result
end

module Time :
sig
  type t = {
    tv_sec : int64;
    tv_usec : int32;
  }

  val gettimeofday : unit -> (t, Error.t) result
end

module Random :
sig
  val random :
    ?loop:Loop.t -> Buffer.t -> ((unit, Error.t) result -> unit) -> unit

  module Sync :
  sig
    val random : Buffer.t -> (unit, Error.t) result
  end
end

module Sleep :
sig
  val sleep : int -> unit
end
