(* Everything is in one file to cut down on Dune boilerplate, as it would grow
   proportionally in the number of files the bindings are spread over.
   https://github.com/ocaml/dune/issues/135. *)

module Make (F : Ctypes.TYPE) =
struct
  open Ctypes
  open F

  module Error =
  struct
    module Private :
    sig
      type t = private int
      val t : t typ
      val success : t
    end =
    struct
      type t = int
      let t = int
      let success = 0
    end
    include Private

    let e2big = constant "UV_E2BIG" t
    let eacces = constant "UV_EACCES" t
    let eaddrinuse = constant "UV_EADDRINUSE" t
    let eaddrnotavail = constant "UV_EADDRNOTAVAIL" t
    let eafnosupport = constant "UV_EAFNOSUPPORT" t
    let eagain = constant "UV_EAGAIN" t
    let eai_addrfamily = constant "UV_EAI_ADDRFAMILY" t
    let eai_again = constant "UV_EAI_AGAIN" t
    let eai_badflags = constant "UV_EAI_BADFLAGS" t
    let eai_badhints = constant "UV_EAI_BADHINTS" t
    let eai_canceled = constant "UV_EAI_CANCELED" t
    let eai_fail = constant "UV_EAI_FAIL" t
    let eai_family = constant "UV_EAI_FAMILY" t
    let eai_memory = constant "UV_EAI_MEMORY" t
    let eai_nodata = constant "UV_EAI_NODATA" t
    let eai_noname = constant "UV_EAI_NONAME" t
    let eai_overflow = constant "UV_EAI_OVERFLOW" t
    let eai_protocol = constant "UV_EAI_PROTOCOL" t
    let eai_service = constant "UV_EAI_SERVICE" t
    let eai_socktype = constant "UV_EAI_SOCKTYPE" t
    let ealready = constant "UV_EALREADY" t
    let ebadf = constant "UV_EBADF" t
    let ebusy = constant "UV_EBUSY" t
    let ecanceled = constant "UV_ECANCELED" t
    let econnaborted = constant "UV_ECONNABORTED" t
    let econnrefused = constant "UV_ECONNREFUSED" t
    let econnreset = constant "UV_ECONNRESET" t
    let edestaddrreq = constant "UV_EDESTADDRREQ" t
    let eexist = constant "UV_EEXIST" t
    let efault = constant "UV_EFAULT" t
    let efbig = constant "UV_EFBIG" t
    let ehostunreach = constant "UV_EHOSTUNREACH" t
    let eintr = constant "UV_EINTR" t
    let einval = constant "UV_EINVAL" t
    let eio = constant "UV_EIO" t
    let eisconn = constant "UV_EISCONN" t
    let eisdir = constant "UV_EISDIR" t
    let eloop = constant "UV_ELOOP" t
    let emfile = constant "UV_EMFILE" t
    let emsgsize = constant "UV_EMSGSIZE" t
    let enametoolong = constant "UV_ENAMETOOLONG" t
    let enetdown = constant "UV_ENETDOWN" t
    let enetunreach = constant "UV_ENETUNREACH" t
    let enfile = constant "UV_ENFILE" t
    let enobufs = constant "UV_ENOBUFS" t
    let enodev = constant "UV_ENODEV" t
    let enoent = constant "UV_ENOENT" t
    let enomem = constant "UV_ENOMEM" t
    let enonet = constant "UV_ENONET" t
    let enoprotoopt = constant "UV_ENOPROTOOPT" t
    let enospc = constant "UV_ENOSPC" t
    let enosys = constant "UV_ENOSYS" t
    let enotconn = constant "UV_ENOTCONN" t
    let enotdir = constant "UV_ENOTDIR" t
    let enotempty = constant "UV_ENOTEMPTY" t
    let enotsock = constant "UV_ENOTSOCK" t
    let enotsup = constant "UV_ENOTSUP" t
    let eperm = constant "UV_EPERM" t
    let epipe = constant "UV_EPIPE" t
    let eproto = constant "UV_EPROTO" t
    let eprotonosupport = constant "UV_EPROTONOSUPPORT" t
    let eprototype = constant "UV_EPROTOTYPE" t
    let erange = constant "UV_ERANGE" t
    let erofs = constant "UV_EROFS" t
    let eshutdown = constant "UV_ESHUTDOWN" t
    let espipe = constant "UV_ESPIPE" t
    let esrch = constant "UV_ESRCH" t
    let etimedout = constant "UV_ETIMEDOUT" t
    let etxtbsy = constant "UV_ETXTBSY" t
    let exdev = constant "UV_EXDEV" t
    let unknown = constant "UV_UNKNOWN" t
    let eof = constant "UV_EOF" t
    let enxio = constant "UV_ENXIO" t
    let emlink = constant "UV_EMLINK" t
  end

  module Version =
  struct
    let major = constant "UV_VERSION_MAJOR" int
    let minor = constant "UV_VERSION_MINOR" int
    let patch = constant "UV_VERSION_PATCH" int
    let is_release = constant "UV_VERSION_IS_RELEASE" bool
    (* TODO How to bind this? *)
    (* let suffix = constant "UV_VERSION_SUFFIX" (ptr char) *)
    let hex = constant "UV_VERSION_HEX" int
  end

  module Loop =
  struct
    module Run_mode =
    struct
      let default = constant "UV_RUN_DEFAULT" int
      let once = constant "UV_RUN_ONCE" int
      let nowait = constant "UV_RUN_NOWAIT" int
    end

    module Option =
    struct
      let block_signal = constant "UV_LOOP_BLOCK_SIGNAL" int
      let sigprof = constant "SIGPROF" int
    end

    type t = [ `Loop ] structure
    let t : t typ = typedef (structure "`Loop") "uv_loop_t"
    let () = seal t
  end

  (* TODO: Infer size and alignment, and/or move this somewhere? *)
  module Buf =
  struct
    type t = [ `Buf ] abstract
    let t : t typ = abstract ~name:"uv_buf_t" ~size:16 ~alignment:8
  end

  module Handle =
  struct
    type 'kind handle
    type 'kind t = ('kind handle) structure
    let t : ([ `Base ] t) typ = typedef (structure "`Handle`") "uv_handle_t"
    let () = seal t

    let callback_count = constant "LUV_HANDLE_GENERIC_CALLBACK_COUNT" int
    let generic_callback_index =
      constant "LUV_HANDLE_GENERIC_CALLBACK_INDEX" int
  end

  module Request =
  struct
    type 'kind request
    type 'kind t = ('kind request) structure
    let t : ([ `Base ] t) typ = typedef (structure "`Request") "uv_req_t"
    let () = seal t
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

    let sigusr1_for_testing = constant "SIGUSR1" int
  end

  (* TODO Fill out. *)
  module Stream =
  struct
    type 'kind stream
    type 'kind t = ('kind stream) Handle.t
    let t : ([ `Base ] t) typ = typedef (structure "`Stream") "uv_stream_t"
    let () = seal t

    let callback_count = constant "LUV_STREAM_CALLBACK_COUNT" int
    let connection_callback_index = constant "LUV_CONNECTION_CALLBACK_INDEX" int
    let read_callback_index = constant "LUV_READ_CALLBACK_INDEX" int
    let allocate_callback_index = constant "LUV_ALLOCATE_CALLBACK_INDEX" int
    let buffer_reference_index = constant "LUV_BUFFER_REFERENCE_INDEX" int

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

  (* Sockaddr helpers from the OCaml Unix module's C code. *)
  module Sockaddr =
  struct
    type t = [ `Sockaddr ] structure
    let t : t typ = structure "sockaddr"
    let () = seal t

    let union : ([ `Sockaddr_union ] union) typ = union "sock_addr_union"
    let s_gen = field union "s_gen" t
    let () = seal union
  end

  module TCP =
  struct
    let ipv6_only = constant "UV_TCP_IPV6ONLY" int

    let t : ([ `TCP ] Stream.t) typ = typedef (structure "`TCP") "uv_tcp_t"
    let () = seal t
  end

  module File =
  struct
    module Request =
    struct
      let t : ([ `File ] Request.t) typ = typedef (structure "`File") "uv_fs_t"
      let () = seal t
    end

    (* TODO This should actually be an abstract type, but it is defined as int
       on both Unix and Windows, so this definition is ok until ctypes is
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

      let isuid = constant "S_ISUID" int
      let isgid = constant "S_ISGID" int
      let isvtx = constant "S_ISVTX" int
    end

    module Dirent =
    struct
      type t = [ `Dirent ] structure
      let t : t typ = typedef (structure "`Dirent") "uv_dirent_t"
      let name = field t "name" string
      let type_ = field t "type" int
      let () = seal t

      (* TODO Actual size of this enum, and the corresponding field? *)
      let file = constant "UV_DIRENT_FILE" int
      let dir = constant "UV_DIRENT_DIR" int
      let link = constant "UV_DIRENT_LINK" int
      let fifo = constant "UV_DIRENT_FIFO" int
      let socket = constant "UV_DIRENT_SOCKET" int
      let char = constant "UV_DIRENT_CHAR" int
      let block = constant "UV_DIRENT_BLOCK" int
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
      let t : ([ `Stat ] structure) typ =
        typedef (structure "`Stat") "uv_stat_t"
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
end
