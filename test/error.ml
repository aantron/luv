(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let tests = [
  "strerror",

  (let t name message constant =
    name, `Quick, (fun () ->
      Alcotest.(check string)
        "description" message (Luv.Error.strerror constant))
  in

  Luv.Error.[
    t "SUCCESS" "Unknown system error 0" success;
    t "E2BIG" "argument list too long" e2big;
    t "EACCES" "permission denied" eacces;
    t "EADDRINUSE" "address already in use" eaddrinuse;
    t "EADDRNOTAVAIL" "address not available" eaddrnotavail;
    t "EAFNOSUPPORT" "address family not supported" eafnosupport;
    t "EAGAIN" "resource temporarily unavailable" eagain;
    t "EAI_ADDRFAMILY" "address family not supported" eai_addrfamily;
    t "EAI_AGAIN" "temporary failure" eai_again;
    t "EAI_BADFLAGS" "bad ai_flags value" eai_badflags;
    t "EAI_BADHINTS" "invalid value for hints" eai_badhints;
    t "EAI_CANCELED" "request canceled" eai_canceled;
    t "EAI_FAIL" "permanent failure" eai_fail;
    t "EAI_FAMILY" "ai_family not supported" eai_family;
    t "EAI_MEMORY" "out of memory" eai_memory;
    t "EAI_NODATA" "no address" eai_nodata;
    t "EAI_NONAME" "unknown node or service" eai_noname;
    t "EAI_OVERFLOW" "argument buffer overflow" eai_overflow;
    t "EAI_PROTOCOL" "resolved protocol is unknown" eai_protocol;
    t "EAI_SERVICE" "service not available for socket type" eai_service;
    t "EAI_SOCKTYPE" "socket type not supported" eai_socktype;
    t "EALREADY" "connection already in progress" ealready;
    t "EBADF" "bad file descriptor" ebadf;
    t "EBUSY" "resource busy or locked" ebusy;
    t "ECANCELED" "operation canceled" ecanceled;
    t "ECONNABORTED" "software caused connection abort" econnaborted;
    t "ECONNREFUSED" "connection refused" econnrefused;
    t "ECONNRESET" "connection reset by peer" econnreset;
    t "EDESTADDRREQ" "destination address required" edestaddrreq;
    t "EEXIST" "file already exists" eexist;
    t "EFAULT" "bad address in system call argument" efault;
    t "EFBIG" "file too large" efbig;
    t "EHOSTUNREACH" "host is unreachable" ehostunreach;
    t "EINTR" "interrupted system call" eintr;
    t "EINVAL" "invalid argument" einval;
    t "EIO" "i/o error" eio;
    t "EISCONN" "socket is already connected" eisconn;
    t "EISDIR" "illegal operation on a directory" eisdir;
    t "ELOOP" "too many symbolic links encountered" eloop;
    t "EMFILE" "too many open files" emfile;
    t "EMSGSIZE" "message too long" emsgsize;
    t "ENAMETOOLONG" "name too long" enametoolong;
    t "ENETDOWN" "network is down" enetdown;
    t "ENETUNREACH" "network is unreachable" enetunreach;
    t "ENFILE" "file table overflow" enfile;
    t "ENOBUFS" "no buffer space available" enobufs;
    t "ENODEV" "no such device" enodev;
    t "ENOENT" "no such file or directory" enoent;
    t "ENOMEM" "not enough memory" enomem;
    t "ENONET" "machine is not on the network" enonet;
    t "ENOPROTOOPT" "protocol not available" enoprotoopt;
    t "ENOSPC" "no space left on device" enospc;
    t "ENOSYS" "function not implemented" enosys;
    t "ENOTCONN" "socket is not connected" enotconn;
    t "ENOTDIR" "not a directory" enotdir;
    t "ENOTEMPTY" "directory not empty" enotempty;
    t "ENOTSOCK" "socket operation on non-socket" enotsock;
    t "ENOTSUP" "operation not supported on socket" enotsup;
    t "EPERM" "operation not permitted" eperm;
    t "EPIPE" "broken pipe" epipe;
    t "EPROTO" "protocol error" eproto;
    t "EPROTONOSUPPORT" "protocol not supported" eprotonosupport;
    t "EPROTOTYPE" "protocol wrong type for socket" eprototype;
    t "ERANGE" "result too large" erange;
    t "EROFS" "read-only file system" erofs;
    t "ESHUTDOWN" "cannot send after transport endpoint shutdown" eshutdown;
    t "ESPIPE" "invalid seek" espipe;
    t "ESRCH" "no such process" esrch;
    t "ETIMEDOUT" "connection timed out" etimedout;
    t "ETXTBSY" "text file is busy" etxtbsy;
    t "EXDEV" "cross-device link not permitted" exdev;
    t "UNKNOWN" "unknown error" unknown;
    t "EOF" "end of file" eof;
    t "ENXIO" "no such device or address" enxio;
    t "EMLINK" "too many links" emlink;
  ]);


  "err_name",

  (let t name constant =
    name, `Quick, (fun () ->
      Alcotest.(check string)
        "error constant name" name (Luv.Error.err_name constant))
  in

  Luv.Error.[
    t "Unknown system error 0" success;
    t "E2BIG" e2big;
    t "EACCES" eacces;
    t "EADDRINUSE" eaddrinuse;
    t "EADDRNOTAVAIL" eaddrnotavail;
    t "EAFNOSUPPORT" eafnosupport;
    t "EAGAIN" eagain;
    t "EAI_ADDRFAMILY" eai_addrfamily;
    t "EAI_AGAIN" eai_again;
    t "EAI_BADFLAGS" eai_badflags;
    t "EAI_BADHINTS" eai_badhints;
    t "EAI_CANCELED" eai_canceled;
    t "EAI_FAIL" eai_fail;
    t "EAI_FAMILY" eai_family;
    t "EAI_MEMORY" eai_memory;
    t "EAI_NODATA" eai_nodata;
    t "EAI_NONAME" eai_noname;
    t "EAI_OVERFLOW" eai_overflow;
    t "EAI_PROTOCOL" eai_protocol;
    t "EAI_SERVICE" eai_service;
    t "EAI_SOCKTYPE" eai_socktype;
    t "EALREADY" ealready;
    t "EBADF" ebadf;
    t "EBUSY" ebusy;
    t "ECANCELED" ecanceled;
    t "ECONNABORTED" econnaborted;
    t "ECONNREFUSED" econnrefused;
    t "ECONNRESET" econnreset;
    t "EDESTADDRREQ" edestaddrreq;
    t "EEXIST" eexist;
    t "EFAULT" efault;
    t "EFBIG" efbig;
    t "EHOSTUNREACH" ehostunreach;
    t "EINTR" eintr;
    t "EINVAL" einval;
    t "EIO" eio;
    t "EISCONN" eisconn;
    t "EISDIR" eisdir;
    t "ELOOP" eloop;
    t "EMFILE" emfile;
    t "EMSGSIZE" emsgsize;
    t "ENAMETOOLONG" enametoolong;
    t "ENETDOWN" enetdown;
    t "ENETUNREACH" enetunreach;
    t "ENFILE" enfile;
    t "ENOBUFS" enobufs;
    t "ENODEV" enodev;
    t "ENOENT" enoent;
    t "ENOMEM" enomem;
    t "ENONET" enonet;
    t "ENOPROTOOPT" enoprotoopt;
    t "ENOSPC" enospc;
    t "ENOSYS" enosys;
    t "ENOTCONN" enotconn;
    t "ENOTDIR" enotdir;
    t "ENOTEMPTY" enotempty;
    t "ENOTSOCK" enotsock;
    t "ENOTSUP" enotsup;
    t "EPERM" eperm;
    t "EPIPE" epipe;
    t "EPROTO" eproto;
    t "EPROTONOSUPPORT" eprotonosupport;
    t "EPROTOTYPE" eprototype;
    t "ERANGE" erange;
    t "EROFS" erofs;
    t "ESHUTDOWN" eshutdown;
    t "ESPIPE" espipe;
    t "ESRCH" esrch;
    t "ETIMEDOUT" etimedout;
    t "ETXTBSY" etxtbsy;
    t "EXDEV" exdev;
    t "UNKNOWN" unknown;
    t "EOF" eof;
    t "ENXIO" enxio;
    t "EMLINK" emlink;
  ]);

  "error", [
    "int", `Quick, begin fun () ->
      (Luv.Error.eagain :> int) |> ignore
    end;

    (* We can't easily get the numeric value of a system error code, so
       round-trip a libuv error code. *)
    "translate_sys_error", `Quick, begin fun () ->
      Luv.Error.translate_sys_error
        (Luv.Error.eagain :> int) [@ocaml.warning "-18"]
      |> Test_helpers.check_error_code "round trip" Luv.Error.eagain
    end;
  ];

]
