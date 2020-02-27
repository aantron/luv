(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(* Everything is in one file to cut down on Dune boilerplate, as it would grow
   proportionally in the number of files the bindings are spread over.
   https://github.com/ocaml/dune/issues/135. *)

module Descriptions (F : Ctypes.TYPE) =
struct
  open Ctypes
  open F

  module Error =
  struct
    let e2big = constant "UV_E2BIG" int
    let eacces = constant "UV_EACCES" int
    let eaddrinuse = constant "UV_EADDRINUSE" int
    let eaddrnotavail = constant "UV_EADDRNOTAVAIL" int
    let eafnosupport = constant "UV_EAFNOSUPPORT" int
    let eagain = constant "UV_EAGAIN" int
    let eai_addrfamily = constant "UV_EAI_ADDRFAMILY" int
    let eai_again = constant "UV_EAI_AGAIN" int
    let eai_badflags = constant "UV_EAI_BADFLAGS" int
    let eai_badhints = constant "UV_EAI_BADHINTS" int
    let eai_canceled = constant "UV_EAI_CANCELED" int
    let eai_fail = constant "UV_EAI_FAIL" int
    let eai_family = constant "UV_EAI_FAMILY" int
    let eai_memory = constant "UV_EAI_MEMORY" int
    let eai_nodata = constant "UV_EAI_NODATA" int
    let eai_noname = constant "UV_EAI_NONAME" int
    let eai_overflow = constant "UV_EAI_OVERFLOW" int
    let eai_protocol = constant "UV_EAI_PROTOCOL" int
    let eai_service = constant "UV_EAI_SERVICE" int
    let eai_socktype = constant "UV_EAI_SOCKTYPE" int
    let ealready = constant "UV_EALREADY" int
    let ebadf = constant "UV_EBADF" int
    let ebusy = constant "UV_EBUSY" int
    let ecanceled = constant "UV_ECANCELED" int
    let econnaborted = constant "UV_ECONNABORTED" int
    let econnrefused = constant "UV_ECONNREFUSED" int
    let econnreset = constant "UV_ECONNRESET" int
    let edestaddrreq = constant "UV_EDESTADDRREQ" int
    let eexist = constant "UV_EEXIST" int
    let efault = constant "UV_EFAULT" int
    let efbig = constant "UV_EFBIG" int
    let ehostunreach = constant "UV_EHOSTUNREACH" int
    let eilseq = constant "UV_EILSEQ" int
    let eintr = constant "UV_EINTR" int
    let einval = constant "UV_EINVAL" int
    let eio = constant "UV_EIO" int
    let eisconn = constant "UV_EISCONN" int
    let eisdir = constant "UV_EISDIR" int
    let eloop = constant "UV_ELOOP" int
    let emfile = constant "UV_EMFILE" int
    let emsgsize = constant "UV_EMSGSIZE" int
    let enametoolong = constant "UV_ENAMETOOLONG" int
    let enetdown = constant "UV_ENETDOWN" int
    let enetunreach = constant "UV_ENETUNREACH" int
    let enfile = constant "UV_ENFILE" int
    let enobufs = constant "UV_ENOBUFS" int
    let enodev = constant "UV_ENODEV" int
    let enoent = constant "UV_ENOENT" int
    let enomem = constant "UV_ENOMEM" int
    let enonet = constant "UV_ENONET" int
    let enoprotoopt = constant "UV_ENOPROTOOPT" int
    let enospc = constant "UV_ENOSPC" int
    let enosys = constant "UV_ENOSYS" int
    let enotconn = constant "UV_ENOTCONN" int
    let enotdir = constant "UV_ENOTDIR" int
    let enotempty = constant "UV_ENOTEMPTY" int
    let enotsock = constant "UV_ENOTSOCK" int
    let enotsup = constant "UV_ENOTSUP" int
    let eperm = constant "UV_EPERM" int
    let epipe = constant "UV_EPIPE" int
    let eproto = constant "UV_EPROTO" int
    let eprotonosupport = constant "UV_EPROTONOSUPPORT" int
    let eprototype = constant "UV_EPROTOTYPE" int
    let erange = constant "UV_ERANGE" int
    let erofs = constant "UV_EROFS" int
    let eshutdown = constant "UV_ESHUTDOWN" int
    let espipe = constant "UV_ESPIPE" int
    let esrch = constant "UV_ESRCH" int
    let etimedout = constant "UV_ETIMEDOUT" int
    let etxtbsy = constant "UV_ETXTBSY" int
    let exdev = constant "UV_EXDEV" int
    let unknown = constant "UV_UNKNOWN" int
    let eof = constant "UV_EOF" int
    let enxio = constant "UV_ENXIO" int
    let emlink = constant "UV_EMLINK" int
  end

  module Version =
  struct
    let major = constant "UV_VERSION_MAJOR" int
    let minor = constant "UV_VERSION_MINOR" int
    let patch = constant "UV_VERSION_PATCH" int
    let is_release = constant "UV_VERSION_IS_RELEASE" bool
    let hex = constant "UV_VERSION_HEX" int
    (* UV_VERSION_SUFFIX cannot be bound as a constant, so it is bound as a
       function returning that constant: C.Functions.Version.suffix. *)
  end

  module Loop =
  struct
    module Run_mode =
    struct
      let default = constant "UV_RUN_DEFAULT" int64_t
      let once = constant "UV_RUN_ONCE" int64_t
      let nowait = constant "UV_RUN_NOWAIT" int64_t

      type t = [
        | `DEFAULT
        | `ONCE
        | `NOWAIT
      ]

      let t : t typ = enum "uv_run_mode" ~typedef:true [
        `DEFAULT, default;
        `ONCE, once;
        `NOWAIT, nowait;
      ]
    end

    module Option =
    struct
      let block_signal = constant "UV_LOOP_BLOCK_SIGNAL" int
      let sigprof = match Sys.win32 with 
      | false -> constant "SIGPROF" int
      | true -> constant "0" int
    end

    type t = [ `Loop ] structure
    let t : t typ = typedef (structure "`Loop") "uv_loop_t"
    let () = seal t
  end

  module Buf =
  struct
    type t = [ `Buf ] structure
    let t : t typ = typedef (structure "`Buf") "uv_buf_t"
    let base = field t "base" (ptr char)
    let len = field t "len" uint
    let () = seal t
  end

  module Os_fd =
  struct
    type t = [ `Os_fd ] structure
    let t : t typ = typedef (structure "`Os_fd") "uv_os_fd_t"
    let () = seal t
  end

  module Os_socket =
  struct
    type t = [ `Os_socket ] structure
    let t : t typ = typedef (structure "`Os_socket") "uv_os_sock_t"
    let () = seal t
  end

  module Handle =
  struct
    module Type =
    struct
      let tcp = constant "UV_TCP" int
      let named_pipe = constant "UV_NAMED_PIPE" int
    end

    type 'kind handle
    type 'kind t = ('kind handle) structure
    let t : ([ `Base ] t) typ = typedef (structure "`Handle`") "uv_handle_t"
    let () = seal t

    let self_reference_index = constant "LUV_SELF_REFERENCE" int
    let generic_callback_index = constant "LUV_GENERIC_CALLBACK" int
    let close_callback_index = constant "LUV_CLOSE_CALLBACK" int
    let default_reference_count = constant "LUV_HANDLE_REFERENCE_COUNT" int
  end

  module Request =
  struct
    type 'kind request
    type 'kind t = ('kind request) structure
    let t : ([ `Base ] t) typ = typedef (structure "`Request") "uv_req_t"
    let () = seal t

    let default_reference_count = constant "LUV_MINIMUM_REFERENCE_COUNT" int
  end

  module Timer =
  struct
    let t : ([ `Timer ] Handle.t) typ =
      typedef (structure "`Timer") "uv_timer_t"
    let () = seal t
  end

  module Prepare =
  struct
    let t : ([ `Prepare ] Handle.t) typ =
      typedef (structure "`Prepare") "uv_prepare_t"
    let () = seal t
  end

  module Check =
  struct
    let t : ([ `Check ] Handle.t) typ =
      typedef (structure "`Check") "uv_check_t"
    let () = seal t
  end

  module Idle =
  struct
    let t : ([ `Idle ] Handle.t) typ =
      typedef (structure "`Idle") "uv_idle_t"
    let () = seal t
  end

  module Async =
  struct
    let t : ([ `Async ] Handle.t) typ =
      typedef (structure "`Async") "uv_async_t"
    let () = seal t
  end

  module Poll =
  struct
    module Event =
    struct
      let readable = constant "UV_READABLE" int
      let writable = constant "UV_WRITABLE" int
      let disconnect = constant "UV_DISCONNECT" int
      let prioritized = constant "UV_PRIORITIZED" int
    end

    let t : ([ `Poll ] Handle.t) typ =
      typedef (structure "`Poll") "uv_poll_t"
    let () = seal t
  end

  module Signal =
  struct
    let t : ([ `Signal ] Handle.t) typ =
      typedef (structure "`Signal") "uv_signal_t"
    let signum = field t "signum" int
    let () = seal t

    module Signum =
    struct
      let sigabrt = constant "SIGABRT" int
      let sigfpe = constant "SIGFPE" int
      let sighup = constant "SIGHUP" int
      let sigill = constant "SIGILL" int
      let sigint = constant "SIGINT" int
      let sigkill = constant "SIGKILL" int
      let sigsegv = constant "SIGSEGV" int
      let sigterm = constant "SIGTERM" int
      let sigwinch = constant "SIGWINCH" int
    end
  end

  module Stream =
  struct
    type 'kind t = [ `Stream of 'kind ] Handle.t
    let t : ([ `Base ] t) typ = typedef (structure "`Stream") "uv_stream_t"
    let () = seal t

    let somaxconn = constant "SOMAXCONN" int

    let reference_count = constant "LUV_STREAM_REFERENCE_COUNT" int
    let connection_callback_index = constant "LUV_CONNECTION_CALLBACK" int
    let allocate_callback_index = constant "LUV_ALLOCATE_CALLBACK" int

    let stream = t

    module Connect_request =
    struct
      type t = [ `Connect ] Request.t
      let t : t typ =
        typedef (structure "`Connect") "uv_connect_t"
      let handle = field t "handle" (ptr stream)
      let () = seal t
    end

    module Shutdown_request =
    struct
      let t : ([ `Shutdown ] Request.t) typ =
        typedef (structure "`Shutdown") "uv_shutdown_t"
      let () = seal t
    end

    module Write_request =
    struct
      let t : ([` Write ] Request.t) typ =
        typedef (structure "`Write") "uv_write_t"
      let () = seal t
    end
  end

  module Sockaddr =
  struct
    type t = [ `Sockaddr ] structure
    let t : t typ = structure "sockaddr"
    let () = seal t

    type in_ = [ `Sockaddr_in ] structure
    let in_ : in_ typ = structure "sockaddr_in"
    let sin_port = field in_ "sin_port" short
    let () = seal in_

    type in6 = [ `Sockaddr_in6 ] structure
    let in6 : in6 typ = structure "sockaddr_in6"
    let sin6_port = field in6 "sin6_port" short
    let () = seal in6

    type storage = [ `Sockaddr_storage ] structure
    let storage : storage typ = structure "sockaddr_storage"
    let family = field storage "ss_family" short
    let () = seal storage
  end

  module Address_family =
  struct
    let unspec = constant "AF_UNSPEC" int
    let inet = constant "AF_INET" int
    let inet6 = constant "AF_INET6" int
  end

  module Socket_type =
  struct
    let stream = constant "SOCK_STREAM" int
    let dgram = constant "SOCK_DGRAM" int
    let raw = constant "SOCK_RAW" int
  end

  module TCP =
  struct
    let ipv6only = constant "UV_TCP_IPV6ONLY" int

    let t : ([ `TCP ] Stream.t) typ = typedef (structure "`TCP") "uv_tcp_t"
    let () = seal t
  end

  module File =
  struct
    module Request =
    struct
      type t = [ `File ] Request.t
      let t : t typ = typedef (structure "`File") "uv_fs_t"
      let () = seal t
    end

    (* This should actually be an abstract type, but it is defined as int on
       both Unix and Windows, so this definition is ok until Ctypes is
       patched. *)
    type t = int
    let t : t typ = int

    module Open_flag =
    struct
      let rdonly = constant "UV_FS_O_RDONLY" int
      let wronly = constant "UV_FS_O_WRONLY" int
      let rdwr = constant "UV_FS_O_RDWR" int

      let creat = constant "UV_FS_O_CREAT" int
      let excl = constant "UV_FS_O_EXCL" int
      let exlock = constant "UV_FS_O_EXLOCK" int
      let noctty = constant "UV_FS_O_NOCTTY" int
      let nofollow = constant "UV_FS_O_NOFOLLOW" int
      let temporary = constant "UV_FS_O_TEMPORARY" int
      let trunc = constant "UV_FS_O_TRUNC" int

      let append = constant "UV_FS_O_APPEND" int
      let direct = constant "UV_FS_O_DIRECT" int
      let dsync = constant "UV_FS_O_DSYNC" int
      let filemap = constant "UV_FS_O_FILEMAP" int
      let noatime = constant "UV_FS_O_NOATIME" int
      let nonblock = constant "UV_FS_O_NONBLOCK" int
      let random = constant "UV_FS_O_RANDOM" int
      let sequential = constant "UV_FS_O_SEQUENTIAL" int
      let short_lived = constant "UV_FS_O_SHORT_LIVED" int
      let symlink = constant "UV_FS_O_SYMLINK" int
      let sync = constant "UV_FS_O_SYNC" int
    end

    module Mode =
    struct
      let irwxu = constant "S_IRWXU" int
      let irusr = constant "S_IRUSR" int
      let iwusr = constant "S_IWUSR" int
      let ixusr = constant "S_IXUSR" int

      let irwxg = constant "S_IRWXG" int
      let irgrp = constant "S_IRGRP" int
      let iwgrp = constant "S_IWGRP" int
      let ixgrp = constant "S_IXGRP" int

      let irwxo = constant "S_IRWXO" int
      let iroth = constant "S_IROTH" int
      let iwoth = constant "S_IWOTH" int
      let ixoth = constant "S_IXOTH" int

      (*let isuid = constant "S_ISUID" int
      let isgid = constant "S_ISGID" int
      let isvtx = constant "S_ISVTX" int*)
    end

    module Dirent =
    struct
      module Kind =
      struct
        let unknown = constant "UV_DIRENT_UNKNOWN" int64_t
        let file = constant "UV_DIRENT_FILE" int64_t
        let dir = constant "UV_DIRENT_DIR" int64_t
        let link = constant "UV_DIRENT_LINK" int64_t
        let fifo = constant "UV_DIRENT_FIFO" int64_t
        let socket = constant "UV_DIRENT_SOCKET" int64_t
        let char = constant "UV_DIRENT_CHAR" int64_t
        let block = constant "UV_DIRENT_BLOCK" int64_t

        type t = [
          | `UNKNOWN
          | `FILE
          | `DIR
          | `LINK
          | `FIFO
          | `SOCKET
          | `CHAR
          | `BLOCK
        ]

        let t : t typ =
          enum
            "uv_dirent_type_t" ~typedef:true ~unexpected:(fun _ -> `UNKNOWN) [
              `UNKNOWN, unknown;
              `FILE, file;
              `DIR, dir;
              `LINK, link;
              `FIFO, fifo;
              `SOCKET, socket;
              `CHAR, char;
              `BLOCK, block;
            ]
      end

      type t = [ `Dirent ] structure
      let t : t typ = typedef (structure "`Dirent") "uv_dirent_t"
      let name = field t "name" string
      let type_ = field t "type" Kind.t
      let () = seal t
    end

    module Dir =
    struct
      type t = [ `Dir ] structure
      let t : t typ = typedef (structure "`Dir") "uv_dir_t"
      let dirents = field t "dirents" (ptr Dirent.t)
      let nentries = field t "nentries" size_t
      let () = seal t
    end

    module Timespec =
    struct
      let t : ([ `Timespec ] structure) typ =
        typedef (structure "`Timespec") "uv_timespec_t"
      let tv_sec = field t "tv_sec" long
      let tv_nsec = field t "tv_nsec" long
      let () = seal t
    end

    module Stat =
    struct
      type t = [ `Stat ] structure
      let t : t typ = typedef (structure "`Stat") "uv_stat_t"
      let st_dev = field t "st_dev" uint64_t
      let st_mode = field t "st_mode" uint64_t
      let st_nlink = field t "st_nlink" uint64_t
      let st_uid = field t "st_uid" uint64_t
      let st_gid = field t "st_gid" uint64_t
      let st_rdev = field t "st_rdev" uint64_t
      let st_ino = field t "st_ino" uint64_t
      let st_size = field t "st_size" uint64_t
      let st_blksize = field t "st_blksize" uint64_t
      let st_blocks = field t "st_blocks" uint64_t
      let st_flags = field t "st_flags" uint64_t
      let st_gen = field t "st_gen" uint64_t
      let st_atim = field t "st_atim" Timespec.t
      let st_mtim = field t "st_mtim" Timespec.t
      let st_ctim = field t "st_ctim" Timespec.t
      let st_birthtim = field t "st_birthtim" Timespec.t
      let () = seal t
    end

    module Statfs =
    struct
      type t = [ `Statfs ] structure
      let t : t typ = typedef (structure "`Statfs") "uv_statfs_t"
      let f_type = field t "f_type" uint64_t
      let f_bsize = field t "f_bsize" uint64_t
      let f_blocks = field t "f_blocks" uint64_t
      let f_bfree = field t "f_bfree" uint64_t
      let f_bavail = field t "f_bavail" uint64_t
      let f_files = field t "f_files" uint64_t
      let f_ffree = field t "f_ffree" uint64_t
      let f_spare = field t "f_spare" (array 4 uint64_t)
      let () = seal t
    end

    module Copy_flag =
    struct
      let excl = constant "UV_FS_COPYFILE_EXCL" int
      let ficlone = constant "UV_FS_COPYFILE_FICLONE" int
      let ficlone_force = constant "UV_FS_COPYFILE_FICLONE_FORCE" int
    end

    module Access_flag =
    struct
      let f = constant "F_OK" int
      let r = constant "R_OK" int
      let w = constant "W_OK" int
      let x = constant "X_OK" int
    end

    module Symlink_flag =
    struct
      let dir = constant "UV_FS_SYMLINK_DIR" int
      let junction = constant "UV_FS_SYMLINK_JUNCTION" int
    end
  end

  module Pipe =
  struct
    module Mode =
    struct
      let readable = Poll.Event.readable
      let writable = Poll.Event.writable
    end

    let t : ([ `Pipe ] Stream.t) typ = typedef (structure "`Pipe") "uv_pipe_t"
    let () = seal t
  end

  module TTY =
  struct
    module Mode =
    struct
      let normal = constant "UV_TTY_MODE_NORMAL" int64_t
      let raw = constant "UV_TTY_MODE_RAW" int64_t
      let io = constant "UV_TTY_MODE_IO" int64_t

      type t = [
        | `NORMAL
        | `RAW
        | `IO
      ]

      let t : t typ =
        enum "uv_tty_mode_t" ~typedef:true [
          `NORMAL, normal;
          `RAW, raw;
          `IO, io;
        ]
    end

    module Vterm_state =
    struct
      let supported = constant "UV_TTY_SUPPORTED" int64_t
      let unsupported = constant "UV_TTY_UNSUPPORTED" int64_t

      type t = [
        | `SUPPORTED
        | `UNSUPPORTED
      ]

      let t : t typ =
        enum "uv_tty_vtermstate_t" ~typedef:true [
          `SUPPORTED, supported;
          `UNSUPPORTED, unsupported;
        ]
    end

    let t : ([ `TTY ] Stream.t) typ = typedef (structure "`TTY") "uv_tty_t"
    let () = seal t
  end

  module UDP =
  struct
    let t : ([ `UDP ] Handle.t) typ = typedef (structure "`UDP") "uv_udp_t"
    let () = seal t

    let reference_count = constant "LUV_UDP_REFERENCE_COUNT" int
    let allocate_callback_index = constant "LUV_UDP_ALLOCATE_CALLBACK" int

    module Send_request =
    struct
      let t : ([ `Send ] Request.t) typ =
        typedef (structure "`Send") "uv_udp_send_t"
      let () = seal t
    end

    module Flag =
    struct
      let ipv6only = constant "UV_UDP_IPV6ONLY" int
      let partial = constant "UV_UDP_PARTIAL" int
      let reuseaddr = constant "UV_UDP_REUSEADDR" int
    end

    module Membership =
    struct
      let leave_group = constant "UV_LEAVE_GROUP" int64_t
      let join_group = constant "UV_JOIN_GROUP" int64_t

      type t = [
        | `LEAVE_GROUP
        | `JOIN_GROUP
      ]

      let t : t typ =
        enum "uv_membership" ~typedef:true [
          `LEAVE_GROUP, leave_group;
          `JOIN_GROUP, join_group;
        ]
    end
  end

  module Process =
  struct
    let t : ([ `Process ] Handle.t) typ =
      typedef (structure "`Process") "uv_process_t"
    let () = seal t

    module Flag =
    struct
      let setuid = constant "UV_PROCESS_SETUID" int
      let setgid = constant "UV_PROCESS_SETGID" int
      let windows_verbatim_arguments =
        constant "UV_PROCESS_WINDOWS_VERBATIM_ARGUMENTS" int
      let detached = constant "UV_PROCESS_DETACHED" int
      let windows_hide = constant "UV_PROCESS_WINDOWS_HIDE" int
      let windows_hide_console = constant "UV_PROCESS_WINDOWS_HIDE_CONSOLE" int
      let windows_hide_gui = constant "UV_PROCESS_WINDOWS_HIDE_GUI" int
    end

    module Redirection =
    struct
      type t = [ `Redirection ] structure
      let t : t typ =
        typedef (structure "`Redirection") "uv_stdio_container_t"
      let flags = field t "flags" int
      let stream = field t "data.stream" (ptr Handle.t)
      let fd = field t "data.fd" int
      let () = seal t

      let ignore = constant "UV_IGNORE" int
      let create_pipe = constant "UV_CREATE_PIPE" int
      let inherit_fd = constant "UV_INHERIT_FD" int
      let inherit_stream = constant "UV_INHERIT_STREAM" int
      let readable_pipe = constant "UV_READABLE_PIPE" int
      let writable_pipe = constant "UV_WRITABLE_PIPE" int
      let overlapped_pipe = constant "UV_OVERLAPPED_PIPE" int
    end
  end

  module FS_event =
  struct
    let t : ([ `FS_event ] Handle.t) typ =
      typedef (structure "`FS_event") "uv_fs_event_t"
    let () = seal t

    module Event =
    struct
      let rename = constant "UV_RENAME" int
      let change = constant "UV_CHANGE" int
    end

    module Flag =
    struct
      let watch_entry = constant "UV_FS_EVENT_WATCH_ENTRY" int
      let stat = constant "UV_FS_EVENT_STAT" int
      let recursive = constant "UV_FS_EVENT_RECURSIVE" int
    end
  end

  module FS_poll =
  struct
    let t : ([ `FS_poll ] Handle.t) typ =
      typedef (structure "`FS_poll") "uv_fs_poll_t"
    let () = seal t
  end

  module DNS =
  struct
    module Addr_info =
    struct
      let t : ([ `Addrinfo ] structure) typ = structure "addrinfo"
      let flags = field t "ai_flags" int
      let family = field t "ai_family" int
      let socktype = field t "ai_socktype" int
      let protocol = field t "ai_protocol" int
      let addrlen = field t "ai_addrlen" int
      let addr = field t "ai_addr" (ptr Sockaddr.t)
      let canonname = field t "ai_canonname" string_opt
      let next = field t "ai_next" (ptr t)
      let () = seal t

      module Request =
      struct
        let underlying = t
        let t : ([ `Addr_info ] Request.t) typ =
          typedef (structure "`Addr_info") "uv_getaddrinfo_t"
        let addrinfo = field t "addrinfo" (ptr underlying)
        let () = seal t
      end

      module Flag =
      struct
        let passive = constant "AI_PASSIVE" int
        let canonname = constant "AI_CANONNAME" int
        let numerichost = constant "AI_NUMERICHOST" int
        let numericserv = constant "AI_NUMERICSERV" int
        let v4mapped = constant "AI_V4MAPPED" int
        let all = constant "AI_ALL" int
        let addrconfig = constant "AI_ADDRCONFIG" int
      end
    end

    module Name_info =
    struct
      let t : ([ `Name_info ] Request.t) typ =
        typedef (structure "`Name_info") "uv_getnameinfo_t"
      let host = field t "host" char
      let service = field t "service" char
      let () = seal t

      let maxhost = constant "NI_MAXHOST" int
      let maxserv = constant "NI_MAXSERV" int

      module Flag =
      struct
        let namereqd = constant "NI_NAMEREQD" int
        let dgram = constant "NI_DGRAM" int
        let nofqdn = constant "NI_NOFQDN" int
        let numerichost = constant "NI_NUMERICHOST" int
        let numericserv = constant "NI_NUMERICSERV" int
      end
    end
  end

  module DLL =
  struct
    type t = [ `Lib ] structure
    let t : t typ = typedef (structure "`Lib") "uv_lib_t"
    let () = seal t
  end

  module Work =
  struct
    let t : ([ `Thread_pool ] Request.t) typ =
      typedef (structure "`Thread_pool") "uv_work_t"
    let () = seal t

    let reference_count = constant "LUV_WORK_REFERENCE_COUNT" int
    let function_index = constant "LUV_WORK_FUNCTION" int
  end

  module Thread =
  struct
    type t = [ `Thread ] structure
    let t : t typ = typedef (structure "`Thread") "uv_thread_t"
    let () = seal t

    module Options =
    struct
      type t = [ `Thread_options ] structure
      let t : t typ =
        typedef (structure "`Thread_options") "uv_thread_options_t"
      let flags = field t "flags" int
      let stack_size = field t "stack_size" size_t
      let () = seal t

      let no_flags = constant "UV_THREAD_NO_FLAGS" int
      let has_stack_size = constant "UV_THREAD_HAS_STACK_SIZE" int
    end
  end

  module TLS =
  struct
    type t = [ `TLS ] structure
    let t : t typ = typedef (structure "`TLS") "uv_key_t"
    let () = seal t
  end

  module Once =
  struct
    type t = [ `Once ] structure
    let t : t typ = typedef (structure "`Once") "uv_once_t"
    let () = seal t
  end

  module Mutex =
  struct
    type t = [ `Mutex ] structure
    let t : t typ = typedef (structure "`Mutex") "uv_mutex_t"
    let () = seal t
  end

  module Rwlock =
  struct
    type t = [ `Rwlock ] structure
    let t : t typ = typedef (structure "`Rwlock") "uv_rwlock_t"
    let () = seal t
  end

  module Semaphore =
  struct
    type t = [ `Semaphore ] structure
    let t : t typ = typedef (structure "`Semaphore") "uv_sem_t"
    let () = seal t
  end

  module Condition =
  struct
    type t = [ `Condition ] structure
    let t : t typ = typedef (structure "`Condition") "uv_cond_t"
    let () = seal t
  end

  module Barrier =
  struct
    type t = [ `Barrier ] structure
    let t : t typ = typedef (structure "`Barrier") "uv_barrier_t"
    let () = seal t
  end

  module Resource =
  struct
    module Timeval =
    struct
      let t : ([ `Timeval ] structure) typ =
        typedef (structure "`Timeval") "uv_timeval_t"
      let sec = field t "tv_sec" long
      let usec = field t "tv_usec" long
      let () = seal t
    end

    module Rusage =
    struct
      let t : ([ `Rusage ] structure) typ =
        typedef (structure "`Rusage") "uv_rusage_t"
      let utime = field t "ru_utime" Timeval.t
      let stime = field t "ru_stime" Timeval.t
      let maxrss = field t "ru_maxrss" uint64_t
      let ixrss = field t "ru_ixrss" uint64_t
      let idrss = field t "ru_idrss" uint64_t
      let isrss = field t "ru_isrss" uint64_t
      let minflt = field t "ru_minflt" uint64_t
      let majflt = field t "ru_majflt" uint64_t
      let nswap = field t "ru_nswap" uint64_t
      let inblock = field t "ru_inblock" uint64_t
      let oublock = field t "ru_oublock" uint64_t
      let msgsnd = field t "ru_msgsnd" uint64_t
      let msgrcv = field t "ru_msgrcv" uint64_t
      let nsignals = field t "ru_nsignals" uint64_t
      let nvcsw = field t "ru_nvcsw" uint64_t
      let nivcsw = field t "ru_nivcsw" uint64_t
      let () = seal t
    end
  end

  module CPU_info =
  struct
    module Times =
    struct
      let t : ([ `Times ] structure) typ = structure "uv_cpu_times_s"
      let user = field t "user" uint64_t
      let nice = field t "nice" uint64_t
      let sys = field t "sys" uint64_t
      let idle = field t "idle" uint64_t
      let irq = field t "irq" uint64_t
      let () = seal t
    end

    let t : ([ `CPU_info ] structure) typ =
      typedef (structure "`CPU_info") "uv_cpu_info_t"
    let model = field t "model" string
    let speed = field t "speed" int
    let times = field t "cpu_times" Times.t
    let () = seal t
  end

  module Network =
  struct
    module Interface_address =
    struct
      let t : ([ `Interface_address ] structure) typ =
        structure "uv_interface_address_s"
      let name = field t "name" string
      let phys_addr = field t "phys_addr" (array 6 char)
      let is_internal = field t "is_internal" bool
      let address4 = field t "address.address4" Sockaddr.in_
      let address6 = field t "address.address6" Sockaddr.in6
      let netmask4 = field t "netmask.netmask4" Sockaddr.in_
      let netmask6 = field t "netmask.netmask6" Sockaddr.in6
      let () = seal t
    end

    let if_namesize = constant "UV_IF_NAMESIZE" int
    let maxhostnamesize = constant "UV_MAXHOSTNAMESIZE" int
  end

  module Passwd =
  struct
    let t : ([ `Passwd ] structure) typ =
      typedef (structure "`Passwd") "uv_passwd_t"
    let username = field t "username" string
    let uid = field t "uid" long
    let gid = field t "gid" long
    let shell = field t "shell" string_opt
    let homedir = field t "homedir" string
    let () = seal t
  end

  module Time =
  struct
    module Timeval =
    struct
      let t : ([ `Timeval64 ] structure) typ =
        typedef (structure "`Timeval64") "uv_timeval64_t"
      let sec = field t "tv_sec" int64_t
      let usec = field t "tv_usec" int32_t
      let () = seal t
    end
  end

  module Env_item =
  struct
    let t : ([ `Env_item ] structure) typ =
      typedef (structure "`Env_item") "uv_env_item_t"
    let name = field t "name" string
    let value = field t "value" string
    let () = seal t
  end

  module Random =
  struct
    module Request =
    struct
      type t = [ `Random ] Request.t
      let t : t typ = typedef (structure "`Random") "uv_random_t"
      let () = seal t
    end
  end
end
