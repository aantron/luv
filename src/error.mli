(* DOC Document that this is private int. *)
(* DOC Document how to convert private int to int. *)
type t = C.Types.Error.t

val success : t

val e2big : t
val eacces : t
val eaddrinuse : t
val eaddrnotavail : t
val eafnosupport : t
val eagain : t
val eai_addrfamily : t
val eai_again : t
val eai_badflags : t
val eai_badhints : t
val eai_canceled : t
val eai_fail : t
val eai_family : t
val eai_memory : t
val eai_nodata : t
val eai_noname : t
val eai_overflow : t
val eai_protocol : t
val eai_service : t
val eai_socktype : t
val ealready : t
val ebadf : t
val ebusy : t
val ecanceled : t
val econnaborted : t
val econnrefused : t
val econnreset : t
val edestaddrreq : t
val eexist : t
val efault : t
val efbig : t
val ehostunreach : t
val eintr : t
val einval : t
val eio : t
val eisconn : t
val eisdir : t
val eloop : t
val emfile : t
val emsgsize : t
val enametoolong : t
val enetdown : t
val enetunreach : t
val enfile : t
val enobufs : t
val enodev : t
val enoent : t
val enomem : t
val enonet : t
val enoprotoopt : t
val enospc : t
val enosys : t
val enotconn : t
val enotdir : t
val enotempty : t
val enotsock : t
val enotsup : t
val eperm : t
val epipe : t
val eproto : t
val eprotonosupport : t
val eprototype : t
val erange : t
val erofs : t
val eshutdown : t
val espipe : t
val esrch : t
val etimedout : t
val etxtbsy : t
val exdev : t
val unknown : t
val eof : t
val enxio : t
val emlink : t

val strerror : t -> string
val err_name : t -> string
val translate_sys_error : int -> t

val on_unhandled_exception : (exn -> unit) -> unit

(**/**)

val to_result : 'a -> t -> ('a, t) Result.result
val to_result_lazy : (unit -> 'a) -> t -> ('a, t) Result.result
val clamp : t -> t
val coerce : int -> t

(* TODO Don't catch exceptions in synchronous callbacks. *)
val catch_exceptions : ('a -> unit) -> ('a -> unit)
val unhandled_exception : exn -> unit
