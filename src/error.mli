(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Error handling.

    See {{:https://aantron.github.io/luv/basics.html#error-handling} {i Error
    handling}} in the user guide and
    {{:http://docs.libuv.org/en/v1.x/errors.html} {i Error handling}} in
    libuv. *)

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
  | `EFTYPE
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
  | `ENOTTY
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
(** Error codes returned by libuv functions.

    Binds {{:http://docs.libuv.org/en/v1.x/errors.html#error-constants} libuv
    error codes}, which resemble
    {{:http://man7.org/linux/man-pages/man3/errno.3.html#DESCRIPTION} Unix error
    codes}.

    [`EFTYPE] is available since Luv 0.5.5 and libuv 1.16.0. [`ENOTTY] is
    available since Luv 0.5.5 and libuv 1.21.0. *)

val strerror : t -> string
(** Returns the error message corresponding to the given error code.

    Binds {{:http://docs.libuv.org/en/v1.x/errors.html#c.uv_strerror_r}
    [uv_strerror_r]}. *)

val err_name : t -> string
(** Returns the name of the given error code.

    Binds {{:http://docs.libuv.org/en/v1.x/errors.html#c.uv_err_name_r}
    [uv_err_name_r]}. *)

val translate_sys_error : int -> t
(** Converts a system error code to a libuv error code.

    Binds {{:http://docs.libuv.org/en/v1.x/errors.html#c.uv_translate_sys_error}
    [uv_translate_sys_error]}. *)

val set_on_unhandled_exception : (exn -> unit) -> unit
(** If user code terminates a callback by raising an exception, the exception
    cannot be allowed to go up the call stack, because the callback was called
    by libuv (rather than OCaml code), and the exception would disrupt libuv
    book-keeping. Luv instead passes the exception to a global Luv exception
    handler. [Luv.Error.set_on_unhandled_exception f] replaces this exception
    handler with [f].

    For example, in

    {[
      Luv.Error.set_on_unhandled_exception f;
      Luv.File.mkdir "foo" (fun _ -> raise Exit);
    ]}

    the exception [Exit] is passed to [f] when [mkdir] calls its callback.

    It is recommended to avoid letting exceptions escape from callbacks in this
    way.

    The default behavior, if {!Luv.Error.set_on_unhandled_exception} is never
    called, is for Luv to print the exception to STDERR and exit the process
    with exit code 2.

    It is recommended not to call {!Luv.Error.set_on_unhandled_exception} from
    libraries based on Luv, but, instead, to leave the decision on how to handle
    exceptions up to the final application. *)



(**/**)

(* Internal functions; do not use. *)

val result_from_c : int -> (_, t) result
val to_result : 'a -> int -> ('a, t) result
val to_result_lazy : (unit -> 'a) -> int -> ('a, t) result
val clamp : int -> int

val catch_exceptions : ('a -> unit) -> ('a -> unit)
val unhandled_exception : exn -> unit
