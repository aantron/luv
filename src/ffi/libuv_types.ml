(* TODO Note that everything is in one file to cut down on Jbuilder boilerplate,
   as it would grow proportionally in the number of files the bindings are
   spread over. https://github.com/ocaml/dune/issues/135. *)

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
      type t = int
      let default = constant "UV_RUN_DEFAULT" int
      let once = constant "UV_RUN_ONCE" int
      let nowait = constant "UV_RUN_NOWAIT" int
    end

    module Option =
    struct
      type 'value t = int
      let block_signal = constant "UV_LOOP_BLOCK_SIGNAL" int
      let sigprof = constant "SIGPROF" int
    end

    type loop
    type t = loop structure
    let t : t typ = structure "uv_loop_s"
    let () = seal t
  end

  (* TODO: Infer size and alignment, and/or move this somewhere? *)
  module Buf =
  struct
    type buf
    type t = buf abstract
    let t : t typ = abstract ~name:"uv_buf_t" ~size:16 ~alignment:8
  end

  (* TODO Finish *)
  module Handle =
  struct
    (* module Type =
    struct
      type t = int
      let unknown = constant "UV_UNKNOWN_HANDLE" int
      let async = constant "UV_ASYNC" int
      let check = constant "UV_CHECK" int
      let fs_event = constant "UV_FS_EVENT" int
      let fs_poll = constant "UV_FS_POLL" int
      let handle = constant "UV_HANDLE" int
      let idle = constant "UV_IDLE" int
      let named_pipe = constant "UV_NAMED_PIPE" int
      let poll = constant "UV_POLL" int
      let prepare = constant "UV_PREPARE" int
      let process = constant "UV_PROCESS" int
      let stream = constant "UV_STREAM" int
      let tcp = constant "UV_TCP" int
      let timer = constant "UV_TIMER" int
      let tty = constant "UV_TTY" int
      let udp = constant "UV_UDP" int
      let signal = constant "UV_SIGNAL" int
      let file = constant "UV_FILE" int
      let max = constant "UV_HANDLE_TYPE_MAX" int
    end *)

    type base_handle
    type 'type_ handles_only (* TODO Document why this is necessary? *)
    type 'type_ t = 'type_ handles_only structure
    let t : (base_handle t) typ = structure "uv_handle_s"
    let () = seal t

    let callback_count = constant "LUV_HANDLE_GENERIC_CALLBACK_COUNT" int
    let generic_callback_index =
      constant "LUV_HANDLE_GENERIC_CALLBACK_INDEX" int
  end

  module Request =
  struct
    (* TODO Get rid of this? *)
    module Type =
    struct
      type t = int
      let unknown = constant "UV_UNKNOWN_REQ" int
      let req = constant "UV_REQ" int
      let connect = constant "UV_CONNECT" int
      let write = constant "UV_WRITE" int
      let shutdown = constant "UV_SHUTDOWN" int
      let udp_send = constant "UV_UDP_SEND" int
      let fs = constant "UV_FS" int
      let work = constant "UV_WORK" int
      let getaddrinfo = constant "UV_GETADDRINFO" int
      let getnameinfo = constant "UV_GETNAMEINFO" int
      let max = constant "UV_REQ_TYPE_MAX" int
    end

    type base_request
    type 'type_ requests_only (* TODO Document why. *)
    type 'type_ t = 'type_ requests_only structure
    let t : (base_request t) typ = structure "uv_req_s"
    let () = seal t
  end

  (* TODO Finish *)
  module Timer =
  struct
    type timer
    type t = timer Handle.t
    let t : t typ = structure "uv_timer_s"
    let () = seal t
  end

  module Prepare =
  struct
    type prepare
    type t = prepare Handle.t
    let t : t typ = structure "uv_prepare_s"
    let () = seal t
  end

  module Check =
  struct
    type check
    type t = check Handle.t
    let t : t typ = structure "uv_check_s"
    let () = seal t
  end

  module Idle =
  struct
    type idle
    type t = idle Handle.t
    let t : t typ = structure "uv_idle_s"
    let () = seal t
  end

  module Async =
  struct
    type async
    type t = async Handle.t
    let t : t typ = structure "uv_async_s"
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

    type poll
    type t = poll Handle.t
    let t : t typ = structure "uv_poll_s"
    let () = seal t
  end

  module Signal =
  struct
    type signal
    type t = signal Handle.t
    let t : t typ = structure "uv_signal_s"
    let signum = field t "signum" int
    let () = seal t

    let sigusr1_for_testing = constant "SIGUSR1" int
  end

  (* TODO Fill out. *)
  module Stream =
  struct
    type base_stream
    type 'type_ streams_only
    type 'type_ t = 'type_ streams_only Handle.t
    let t : (base_stream t) typ = structure "uv_stream_s"
    (* TODO Fields? *)
    let () = seal t

    let callback_count = constant "LUV_STREAM_CALLBACK_COUNT" int
    let connection_callback_index = constant "LUV_CONNECTION_CALLBACK_INDEX" int
    let read_callback_index = constant "LUV_READ_CALLBACK_INDEX" int
    let allocate_callback_index = constant "LUV_ALLOCATE_CALLBACK_INDEX" int
    let buffer_reference_index = constant "LUV_BUFFER_REFERENCE_INDEX" int

    let stream = t

    module Connect_request =
    struct
      type connect
      type t = connect Request.t
      let t : t typ = structure "uv_connect_s"
      let handle = field t "handle" (ptr stream)
      let () = seal t
    end

    module Shutdown_request =
    struct
      type shutdown
      type t = shutdown Request.t
      let t : t typ = structure "uv_shutdown_s"
      let () = seal t
    end

    module Write_request =
    struct
      type write
      type t = write Request.t
      let t : t typ = structure "uv_write_s"
      let () = seal t
    end
  end

  (* TODO Rename gen -> t, t -> union. *)
  (* Sockaddr helpers from the OCaml Unix module. *)
  module Sockaddr =
  struct
    type sockaddr
    type gen = sockaddr structure
    let gen : gen typ = structure "sockaddr"
    let () = seal gen

    type sockaddr_union
    type t = sockaddr union
    let t : t typ = union "sock_addr_union"
    let s_gen = field t "s_gen" gen
    let () = seal t
  end

  module TCP =
  struct
    let ipv6_only = constant "UV_TCP_IPV6ONLY" int

    type tcp
    type t = tcp Stream.t
    let t : t typ = structure "uv_tcp_s"
    let () = seal t
  end

  (* module Misc =
  struct
    module Os_fd =
    struct
      type os_fd
      type t = os_fd abstract
      let t : t typ = abstract ~name:"uv_os_fd_t" ~size:5 ?alignment:None
    end
  end *)
end
