(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [
  | `E2BIG
  | `EACCES
  | `EADDRINUSE
  | `EADDRNOTAVAIL
  | `EAFNOSUPPORT
  | `EAGAIN
  | `EAI_ADDRFAMILY
  | `EAI_AGAIN
  | `EAI_BADFLAGS
  | `EAI_BADHINTS
  | `EAI_CANCELED
  | `EAI_FAIL
  | `EAI_FAMILY
  | `EAI_MEMORY
  | `EAI_NODATA
  | `EAI_NONAME
  | `EAI_OVERFLOW
  | `EAI_PROTOCOL
  | `EAI_SERVICE
  | `EAI_SOCKTYPE
  | `EALREADY
  | `EBADF
  | `EBUSY
  | `ECANCELED
  | `ECONNABORTED
  | `ECONNREFUSED
  | `ECONNRESET
  | `EDESTADDRREQ
  | `EEXIST
  | `EFAULT
  | `EFBIG
  | `EHOSTUNREACH
  | `EILSEQ
  | `EINTR
  | `EINVAL
  | `EIO
  | `EISCONN
  | `EISDIR
  | `ELOOP
  | `EMFILE
  | `EMSGSIZE
  | `ENAMETOOLONG
  | `ENETDOWN
  | `ENETUNREACH
  | `ENFILE
  | `ENOBUFS
  | `ENODEV
  | `ENOENT
  | `ENOMEM
  | `ENONET
  | `ENOPROTOOPT
  | `ENOSPC
  | `ENOSYS
  | `ENOTCONN
  | `ENOTDIR
  | `ENOTEMPTY
  | `ENOTSOCK
  | `ENOTSUP
  | `EPERM
  | `EPIPE
  | `EPROTO
  | `EPROTONOSUPPORT
  | `EPROTOTYPE
  | `ERANGE
  | `EROFS
  | `ESHUTDOWN
  | `ESPIPE
  | `ESRCH
  | `ETIMEDOUT
  | `ETXTBSY
  | `EXDEV
  | `UNKNOWN
  | `EOF
  | `ENXIO
  | `EMLINK
]

val strerror : t -> string
val err_name : t -> string
val translate_sys_error : int -> t

val on_unhandled_exception : (exn -> unit) -> unit

(**/**)

val from_c : int -> t
val result_from_c : int -> (_, t) Result.result
val to_result : 'a -> int -> ('a, t) Result.result
val to_result_lazy : (unit -> 'a) -> int -> ('a, t) Result.result
val clamp : int -> int

(* TODO Don't catch exceptions in synchronous callbacks. *)
val catch_exceptions : ('a -> unit) -> ('a -> unit)
val unhandled_exception : exn -> unit
