(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let tests = [
  "strerror",

  (let t name message constant =
    name, `Quick, (fun () ->
      Alcotest.(check string)
        "description" message (Luv.Error.strerror constant))
  in

  [
    t "E2BIG" "argument list too long" `E2BIG;
    t "EACCES" "permission denied" `EACCES;
    t "EADDRINUSE" "address already in use" `EADDRINUSE;
    t "EADDRNOTAVAIL" "address not available" `EADDRNOTAVAIL;
    t "EAFNOSUPPORT" "address family not supported" `EAFNOSUPPORT;
    t "EAGAIN" "resource temporarily unavailable" `EAGAIN;
    t "EAI_ADDRFAMILY" "address family not supported" `EAI_ADDRFAMILY;
    t "EAI_AGAIN" "temporary failure" `EAI_AGAIN;
    t "EAI_BADFLAGS" "bad ai_flags value" `EAI_BADFLAGS;
    t "EAI_BADHINTS" "invalid value for hints" `EAI_BADHINTS;
    t "EAI_CANCELED" "request canceled" `EAI_CANCELED;
    t "EAI_FAIL" "permanent failure" `EAI_FAIL;
    t "EAI_FAMILY" "ai_family not supported" `EAI_FAMILY;
    t "EAI_MEMORY" "out of memory" `EAI_MEMORY;
    t "EAI_NODATA" "no address" `EAI_NODATA;
    t "EAI_NONAME" "unknown node or service" `EAI_NONAME;
    t "EAI_OVERFLOW" "argument buffer overflow" `EAI_OVERFLOW;
    t "EAI_PROTOCOL" "resolved protocol is unknown" `EAI_PROTOCOL;
    t "EAI_SERVICE" "service not available for socket type" `EAI_SERVICE;
    t "EAI_SOCKTYPE" "socket type not supported" `EAI_SOCKTYPE;
    t "EALREADY" "connection already in progress" `EALREADY;
    t "EBADF" "bad file descriptor" `EBADF;
    t "EBUSY" "resource busy or locked" `EBUSY;
    t "ECANCELED" "operation canceled" `ECANCELED;
    t "ECONNABORTED" "software caused connection abort" `ECONNABORTED;
    t "ECONNREFUSED" "connection refused" `ECONNREFUSED;
    t "ECONNRESET" "connection reset by peer" `ECONNRESET;
    t "EDESTADDRREQ" "destination address required" `EDESTADDRREQ;
    t "EEXIST" "file already exists" `EEXIST;
    t "EFAULT" "bad address in system call argument" `EFAULT;
    t "EFBIG" "file too large" `EFBIG;
    t "EFTYPE" "inappropriate file type or format" `EFTYPE;
    t "EHOSTUNREACH" "host is unreachable" `EHOSTUNREACH;
    t "EILSEQ" "illegal byte sequence" `EILSEQ;
    t "EINTR" "interrupted system call" `EINTR;
    t "EINVAL" "invalid argument" `EINVAL;
    t "EIO" "i/o error" `EIO;
    t "EISCONN" "socket is already connected" `EISCONN;
    t "EISDIR" "illegal operation on a directory" `EISDIR;
    t "ELOOP" "too many symbolic links encountered" `ELOOP;
    t "EMFILE" "too many open files" `EMFILE;
    t "EMSGSIZE" "message too long" `EMSGSIZE;
    t "ENAMETOOLONG" "name too long" `ENAMETOOLONG;
    t "ENETDOWN" "network is down" `ENETDOWN;
    t "ENETUNREACH" "network is unreachable" `ENETUNREACH;
    t "ENFILE" "file table overflow" `ENFILE;
    t "ENOBUFS" "no buffer space available" `ENOBUFS;
    t "ENODATA" "no data available" `ENODATA;
    t "ENODEV" "no such device" `ENODEV;
    t "ENOENT" "no such file or directory" `ENOENT;
    t "ENOMEM" "not enough memory" `ENOMEM;
    t "ENONET" "machine is not on the network" `ENONET;
    t "ENOPROTOOPT" "protocol not available" `ENOPROTOOPT;
    t "ENOSPC" "no space left on device" `ENOSPC;
    t "ENOSYS" "function not implemented" `ENOSYS;
    t "ENOTCONN" "socket is not connected" `ENOTCONN;
    t "ENOTDIR" "not a directory" `ENOTDIR;
    t "ENOTEMPTY" "directory not empty" `ENOTEMPTY;
    t "ENOTSOCK" "socket operation on non-socket" `ENOTSOCK;
    t "ENOTSUP" "operation not supported on socket" `ENOTSUP;
    t "ENOTTY" "inappropriate ioctl for device" `ENOTTY;
    t "EOVERFLOW" "value too large for defined data type" `EOVERFLOW;
    t "EPERM" "operation not permitted" `EPERM;
    t "EPIPE" "broken pipe" `EPIPE;
    t "EPROTO" "protocol error" `EPROTO;
    t "EPROTONOSUPPORT" "protocol not supported" `EPROTONOSUPPORT;
    t "EPROTOTYPE" "protocol wrong type for socket" `EPROTOTYPE;
    t "ERANGE" "result too large" `ERANGE;
    t "EROFS" "read-only file system" `EROFS;
    t "ESHUTDOWN" "cannot send after transport endpoint shutdown" `ESHUTDOWN;
    t "ESOCKTNOSUPPORT" "socket type not supported" `ESOCKTNOSUPPORT;
    t "ESPIPE" "invalid seek" `ESPIPE;
    t "ESRCH" "no such process" `ESRCH;
    t "ETIMEDOUT" "connection timed out" `ETIMEDOUT;
    t "ETXTBSY" "text file is busy" `ETXTBSY;
    t "EXDEV" "cross-device link not permitted" `EXDEV;
    t "UNKNOWN" "unknown error" `UNKNOWN;
    t "EOF" "end of file" `EOF;
    t "ENXIO" "no such device or address" `ENXIO;
    t "EMLINK" "too many links" `EMLINK;
  ]);


  "err_name",

  (let t name constant =
    name, `Quick, (fun () ->
      Alcotest.(check string)
        "error constant name" name (Luv.Error.err_name constant))
  in

  [
    t "E2BIG" `E2BIG;
    t "EACCES" `EACCES;
    t "EADDRINUSE" `EADDRINUSE;
    t "EADDRNOTAVAIL" `EADDRNOTAVAIL;
    t "EAFNOSUPPORT" `EAFNOSUPPORT;
    t "EAGAIN" `EAGAIN;
    t "EAI_ADDRFAMILY" `EAI_ADDRFAMILY;
    t "EAI_AGAIN" `EAI_AGAIN;
    t "EAI_BADFLAGS" `EAI_BADFLAGS;
    t "EAI_BADHINTS" `EAI_BADHINTS;
    t "EAI_CANCELED" `EAI_CANCELED;
    t "EAI_FAIL" `EAI_FAIL;
    t "EAI_FAMILY" `EAI_FAMILY;
    t "EAI_MEMORY" `EAI_MEMORY;
    t "EAI_NODATA" `EAI_NODATA;
    t "EAI_NONAME" `EAI_NONAME;
    t "EAI_OVERFLOW" `EAI_OVERFLOW;
    t "EAI_PROTOCOL" `EAI_PROTOCOL;
    t "EAI_SERVICE" `EAI_SERVICE;
    t "EAI_SOCKTYPE" `EAI_SOCKTYPE;
    t "EALREADY" `EALREADY;
    t "EBADF" `EBADF;
    t "EBUSY" `EBUSY;
    t "ECANCELED" `ECANCELED;
    t "ECONNABORTED" `ECONNABORTED;
    t "ECONNREFUSED" `ECONNREFUSED;
    t "ECONNRESET" `ECONNRESET;
    t "EDESTADDRREQ" `EDESTADDRREQ;
    t "EEXIST" `EEXIST;
    t "EFAULT" `EFAULT;
    t "EFBIG" `EFBIG;
    t "EFTYPE" `EFTYPE;
    t "EHOSTUNREACH" `EHOSTUNREACH;
    t "EILSEQ" `EILSEQ;
    t "EINTR" `EINTR;
    t "EINVAL" `EINVAL;
    t "EIO" `EIO;
    t "EISCONN" `EISCONN;
    t "EISDIR" `EISDIR;
    t "ELOOP" `ELOOP;
    t "EMFILE" `EMFILE;
    t "EMSGSIZE" `EMSGSIZE;
    t "ENAMETOOLONG" `ENAMETOOLONG;
    t "ENETDOWN" `ENETDOWN;
    t "ENETUNREACH" `ENETUNREACH;
    t "ENFILE" `ENFILE;
    t "ENOBUFS" `ENOBUFS;
    t "ENODATA" `ENODATA;
    t "ENODEV" `ENODEV;
    t "ENOENT" `ENOENT;
    t "ENOMEM" `ENOMEM;
    t "ENONET" `ENONET;
    t "ENOPROTOOPT" `ENOPROTOOPT;
    t "ENOSPC" `ENOSPC;
    t "ENOSYS" `ENOSYS;
    t "ENOTCONN" `ENOTCONN;
    t "ENOTDIR" `ENOTDIR;
    t "ENOTEMPTY" `ENOTEMPTY;
    t "ENOTSOCK" `ENOTSOCK;
    t "ENOTSUP" `ENOTSUP;
    t "EOVERFLOW" `EOVERFLOW;
    t "ENOTTY" `ENOTTY;
    t "EPERM" `EPERM;
    t "EPIPE" `EPIPE;
    t "EPROTO" `EPROTO;
    t "EPROTONOSUPPORT" `EPROTONOSUPPORT;
    t "EPROTOTYPE" `EPROTOTYPE;
    t "ERANGE" `ERANGE;
    t "EROFS" `EROFS;
    t "ESHUTDOWN" `ESHUTDOWN;
    t "ESOCKTNOSUPPORT" `ESOCKTNOSUPPORT;
    t "ESPIPE" `ESPIPE;
    t "ESRCH" `ESRCH;
    t "ETIMEDOUT" `ETIMEDOUT;
    t "ETXTBSY" `ETXTBSY;
    t "EXDEV" `EXDEV;
    t "UNKNOWN" `UNKNOWN;
    t "EOF" `EOF;
    t "ENXIO" `ENXIO;
    t "EMLINK" `EMLINK;
  ]);
]
