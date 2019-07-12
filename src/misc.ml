(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Os_fd =
struct
  type t = C.Types.Os_fd.t

  external from_unix_helper : Unix.file_descr -> nativeint -> unit =
    "luv_unix_fd_to_os_fd"

  let from_unix unix_fd =
    let os_fd = Ctypes.make C.Types.Os_fd.t in
    let storage = Ctypes.(raw_address_of_ptr (to_voidp (addr os_fd))) in
    from_unix_helper unix_fd storage;
    if C.Functions.Os_fd.is_invalid_handle_value os_fd then
      Result.Error Error.ebadf
    else
      Result.Ok os_fd

  external to_unix_helper : nativeint -> Unix.file_descr =
    "luv_os_fd_to_unix_fd"

  let to_unix os_fd =
    to_unix_helper (Ctypes.(raw_address_of_ptr (to_voidp (addr os_fd))))
end

module Os_socket =
struct
  type t = C.Types.Os_socket.t

  external from_unix_helper : Unix.file_descr -> nativeint -> unit =
    "luv_unix_fd_to_os_socket"

  let from_unix unix_fd =
    let os_socket = Ctypes.make C.Types.Os_socket.t in
    let storage = Ctypes.(raw_address_of_ptr (to_voidp (addr os_socket))) in
    from_unix_helper unix_fd storage;
    if C.Functions.Os_socket.is_invalid_socket_value os_socket then
      Result.Error Error.ebadf
    else
      Result.Ok os_socket

  external to_unix_helper : nativeint -> Unix.file_descr =
    "luv_os_socket_to_unix_fd"

  let to_unix os_socket =
    to_unix_helper (Ctypes.(raw_address_of_ptr (to_voidp (addr os_socket))))
end

module Address_family =
struct
  include C.Types.Address_family
  type t = int
  let custom i = i
end

module Socket_type =
struct
  include C.Types.Socket_type
  type t = int
  let custom i = i
end

module Sockaddr =
struct
  type t = C.Types.Sockaddr.storage

  let make () =
    Ctypes.make C.Types.Sockaddr.storage

  let as_sockaddr address =
    Ctypes.(coerce
      (ptr C.Types.Sockaddr.storage) (ptr C.Types.Sockaddr.t) (addr address))

  let null =
    Ctypes.(coerce (ptr void) (ptr C.Types.Sockaddr.t) null)

  let as_in address =
    Ctypes.(coerce
      (ptr C.Types.Sockaddr.storage) (ptr C.Types.Sockaddr.in_) (addr address))

  let as_in6 address =
    Ctypes.(coerce
      (ptr C.Types.Sockaddr.storage) (ptr C.Types.Sockaddr.in6) (addr address))

  let from_string c_function coerce ip port =
    let storage = make () in
    c_function (Ctypes.ocaml_string_start ip) port (coerce storage)
    |> Error.to_result storage

  let ipv4 = from_string C.Functions.Sockaddr.ip4_addr as_in
  let ipv6 = from_string C.Functions.Sockaddr.ip6_addr as_in6

  let finish_to_string c_function coerce storage =
    let buffer_size = 64 in
    let buffer = Bytes.create buffer_size in
    c_function
      (coerce storage)
      (Ctypes.ocaml_bytes_start buffer)
      (Unsigned.Size_t.of_int buffer_size)
    |> ignore;
    let length = Bytes.index buffer '\000' in
    Bytes.sub_string buffer 0 length

  let to_string storage =
    let family = Ctypes.getf storage C.Types.Sockaddr.family in
    if family = Address_family.inet then
      finish_to_string C.Functions.Sockaddr.ip4_name as_in storage
    else if family = Address_family.inet6 then
      finish_to_string C.Functions.Sockaddr.ip6_name as_in6 storage
    else
      ""

  let port storage =
    let family = Ctypes.getf storage C.Types.Sockaddr.family in
    let network_order_port =
      if family = Address_family.inet then
        Ctypes.(getf (!@ (as_in storage)) C.Types.Sockaddr.sin_port)
      else if family = Address_family.inet6 then
        Ctypes.(getf (!@ (as_in6 storage)) C.Types.Sockaddr.sin6_port)
      else
        0
    in
    C.Functions.Sockaddr.ntohs network_order_port

  let copy_storage address =
    let storage = make () in
    Ctypes.(addr storage <-@ !@ address);
    storage

  let copy_sockaddr address length =
    let storage = make () in
    C.Functions.Sockaddr.memcpy_from_sockaddr
      (Ctypes.addr storage) address length;
    storage

  let wrap_c_getter c_function handle =
    let storage = make () in
    let length =
      Ctypes.(allocate int) (Ctypes.sizeof C.Types.Sockaddr.storage) in
    c_function handle (as_sockaddr storage) length
    |> Error.to_result storage
end

module Resource =
struct
  let resident_set_memory_size () =
    let size = Ctypes.(allocate size_t Unsigned.Size_t.zero) in
    C.Functions.Resource.resident_set_memory size
    |> Error.to_result (Ctypes.(!@) size)

  let uptime () =
    let time = Ctypes.(allocate double) 0. in
    C.Functions.Resource.uptime time
    |> Error.to_result (Ctypes.(!@) time)

  let loadavg () =
    let averages = Ctypes.(allocate_n double) ~count:3 in
    C.Functions.Resource.loadavg averages;
    let open Ctypes in
    (!@ averages, !@ (averages +@ 1), !@ (averages +@ 2))

  let free_memory =
    C.Functions.Resource.free_memory

  let total_memory =
    C.Functions.Resource.total_memory

  let constrained_memory () =
    let result = C.Functions.Resource.constrained_memory () in
    if result = Unsigned.UInt64.zero then
      None
    else
      Some result

  let getpriority pid =
    let priority = Ctypes.(allocate int) 0 in
    C.Functions.Resource.getpriority pid priority
    |> Error.to_result (Ctypes.(!@) priority)

  let setpriority =
    C.Functions.Resource.setpriority

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

  let load_timeval c_timeval =
    {
      sec = Ctypes.getf c_timeval C.Types.Resource.Timeval.sec;
      usec = Ctypes.getf c_timeval C.Types.Resource.Timeval.usec;
    }

  let rusage () =
    let c_rusage = Ctypes.make C.Types.Resource.Rusage.t in
    C.Functions.Resource.rusage (Ctypes.addr c_rusage)
    |> Error.to_result_lazy begin fun () ->
      let module RU = C.Types.Resource.Rusage in
      let field name = Ctypes.getf c_rusage name in
      {
        utime = field RU.utime |> load_timeval;
        stime = field RU.stime |> load_timeval;
        maxrss = field RU.maxrss;
        ixrss = field RU.ixrss;
        idrss = field RU.idrss;
        isrss = field RU.isrss;
        minflt = field RU.minflt;
        majflt = field RU.majflt;
        nswap = field RU.nswap;
        inblock = field RU.inblock;
        oublock = field RU.oublock;
        msgsnd = field RU.msgsnd;
        msgrcv = field RU.msgrcv;
        nsignals = field RU.nsignals;
        nvcsw = field RU.nvcsw;
        nivcsw = field RU.nivcsw;
      }
    end
end

module Pid = C.Functions.Pid

module CPU_info =
struct
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

  let get () =
    let null = Ctypes.(coerce (ptr void) (ptr C.Types.CPU_info.t) null) in
    let info = Ctypes.(allocate (ptr C.Types.CPU_info.t)) null in
    let count = Ctypes.(allocate int) 0 in

    C.Functions.CPU_info.cpu_info info count
    |> Error.to_result_lazy begin fun () ->
      let info = Ctypes.(!@) info in
      let count = Ctypes.(!@) count in

      let rec convert_info index =
        if index >= count then
          []
        else begin
          let module CI = C.Types.CPU_info in
          let c_cpu_info = Ctypes.(!@ (info +@ index)) in
          let c_times = Ctypes.getf c_cpu_info CI.times in
          let cpu_info = {
            model = Ctypes.getf c_cpu_info CI.model;
            speed = Ctypes.getf c_cpu_info CI.speed;
            times = {
              user = Ctypes.getf c_times CI.Times.user;
              nice = Ctypes.getf c_times CI.Times.nice;
              sys = Ctypes.getf c_times CI.Times.sys;
              idle = Ctypes.getf c_times CI.Times.idle;
              irq = Ctypes.getf c_times CI.Times.irq;
            };
          }
          in
          cpu_info::(convert_info (index + 1))
        end
      in
      let cpu_times = convert_info 0 in
      C.Functions.CPU_info.free_cpu_info info count;
      cpu_times
    end
end

module Network =
struct
  let generic_toname c_function index =
    let length = C.Types.Network.if_namesize in
    let buffer = Bytes.create length in
    c_function
      (Unsigned.UInt.of_int index)
      (Ctypes.ocaml_bytes_start buffer)
      (Ctypes.(allocate size_t) (Unsigned.Size_t.of_int length))
    |> Error.to_result_lazy begin fun () ->
      let length = Bytes.index buffer '\000' in
      Bytes.sub_string buffer 0 length
    end

  let if_indextoname = generic_toname C.Functions.Network.if_indextoname
  let if_indextoiid = generic_toname C.Functions.Network.if_indextoiid

  (* TODO There is some common code to factor out here. *)
  let gethostname () =
    let length = C.Types.Network.maxhostnamesize in
    let buffer = Bytes.create length in
    C.Functions.Network.gethostname
      (Ctypes.ocaml_bytes_start buffer)
      (Ctypes.(allocate size_t) (Unsigned.Size_t.of_int length))
    |> Error.to_result_lazy begin fun () ->
      let length = Bytes.index buffer '\000' in
      Bytes.sub_string buffer 0 length
    end
end

module Path =
struct
  let exepath () =
    let length = 4096 in
    let buffer = Bytes.create length in
    C.Functions.Path.exepath
      (Ctypes.ocaml_bytes_start buffer)
      (Ctypes.(allocate size_t) (Unsigned.Size_t.of_int length))
    |> Error.to_result_lazy begin fun () ->
      let length = Bytes.index buffer '\000' in
      Bytes.sub_string buffer 0 length
    end

  let cwd () =
    let length = 4096 in
    let buffer = Bytes.create length in
    C.Functions.Path.cwd
      (Ctypes.ocaml_bytes_start buffer)
      (Ctypes.(allocate size_t) (Unsigned.Size_t.of_int length))
    |> Error.to_result_lazy begin fun () ->
      let length = Bytes.index buffer '\000' in
      Bytes.sub_string buffer 0 length
    end

  let chdir path =
    C.Functions.Path.chdir (Ctypes.ocaml_string_start path)

  let homedir () =
    let length = 1024 in
    let buffer = Bytes.create length in
    C.Functions.Path.homedir
      (Ctypes.ocaml_bytes_start buffer)
      (Ctypes.(allocate size_t) (Unsigned.Size_t.of_int length))
    |> Error.to_result_lazy begin fun () ->
      let length = Bytes.index buffer '\000' in
      Bytes.sub_string buffer 0 length
    end

  let tmpdir () =
    let length = 1024 in
    let buffer = Bytes.create length in
    C.Functions.Path.tmpdir
      (Ctypes.ocaml_bytes_start buffer)
      (Ctypes.(allocate size_t) (Unsigned.Size_t.of_int length))
    |> Error.to_result_lazy begin fun () ->
      let length = Bytes.index buffer '\000' in
      Bytes.sub_string buffer 0 length
    end
end

module Passwd =
struct
  type t = {
    username : string;
    uid : int;
    gid : int;
    shell : string option;
    homedir : string;
  }

  let get () =
    let c_passwd = Ctypes.make C.Types.Passwd.t in
    C.Functions.Passwd.get (Ctypes.addr c_passwd)
    |> Error.to_result_lazy begin fun () ->
      let module PW = C.Types.Passwd in
      let passwd = {
        username = Ctypes.getf c_passwd PW.username;
        uid = Ctypes.getf c_passwd PW.uid |> Signed.Long.to_int;
        gid = Ctypes.getf c_passwd PW.gid |> Signed.Long.to_int;
        shell = Ctypes.getf c_passwd PW.shell;
        homedir = Ctypes.getf c_passwd PW.homedir;
      }
      in
      C.Functions.Passwd.free (Ctypes.addr c_passwd);
      passwd
    end
end

module Hrtime =
struct
  let now =
    C.Functions.Hrtime.hrtime
end

module Env =
struct
  let getenv variable =
    let length = 1024 in
    let buffer = Bytes.create length in
    C.Functions.Env.getenv
      (Ctypes.ocaml_string_start variable)
      (Ctypes.ocaml_bytes_start buffer)
      (Ctypes.(allocate size_t) (Unsigned.Size_t.of_int length))
    |> Error.to_result_lazy begin fun () ->
      let length = Bytes.index buffer '\000' in
      Bytes.sub_string buffer 0 length
    end

  let setenv variable value =
    C.Functions.Env.setenv
      (Ctypes.ocaml_string_start variable) (Ctypes.ocaml_string_start value)

  let unsetenv variable =
    C.Functions.Env.unsetenv (Ctypes.ocaml_string_start variable)
end

module System_name =
struct
  type t = {
    sysname : string;
    release : string;
    version : string;
    machine : string;
  }

  let field_length = 256

  let extract_field buffer index =
    let offset = index * field_length in
    let length =
      match Bytes.index_from buffer offset '\000' with
      | n when n < offset + field_length -> n - offset
      | _ -> field_length
      | exception Not_found -> field_length
    in
    Bytes.sub_string buffer offset length

  let uname () =
    let buffer = Bytes.create (field_length * 4) in
    C.Functions.System_name.uname (Ctypes.ocaml_bytes_start buffer)
    |> Error.to_result_lazy begin fun () ->
      {
        sysname = extract_field buffer 0;
        release = extract_field buffer 1;
        version = extract_field buffer 2;
        machine = extract_field buffer 3;
      }
    end
end

module Time =
struct
  type t = {
    tv_sec : int64;
    tv_usec : int32;
  }

  let gettimeofday () =
    let timeval = Ctypes.make C.Types.Time.Timeval.t in
    C.Functions.Time.gettimeofday (Ctypes.addr timeval)
    |> Error.to_result_lazy begin fun () ->
      {
        tv_sec = Ctypes.getf timeval C.Types.Time.Timeval.sec;
        tv_usec = Ctypes.getf timeval C.Types.Time.Timeval.usec;
      }
    end
end
