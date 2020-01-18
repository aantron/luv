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

(** Error handling. See {{:http://docs.libuv.org/en/v1.x/errors.html} {i Error
    handling}} in the libuv documentation. *)



(** {1 Error code type and helpers} *)

(* type t = C.Types.Error.t *)
(** Type of {{!codes} error codes} returned by libuv functions.

    Note that Luv never raises its own exceptions. All errors are communicated
    by passing error codes of this type, [Luv.Error.t], to callbacks. For
    synchronous calls, the error codes are returned directly.

    Most functions exposed by Luv are asynchronous, and have one of two kinds of
    signatures:

    {ol
      {- If a function simply succeeds or fails, the signature is

        {[
          fn : arguments -> (Luv.Error.t -> unit) -> unit
        ]}

        In this case, success is indicated by passing {!Luv.Error.success} to
        the callback, and failure by passing any other {{!codes} error code}.
      }

      {- If a function returns a useful value when it succeeds, the signature is

        {[
          fn : arguments -> ((value, Luv.Error.t) result -> unit) -> unit
        ]}

        In this case, success is indicated by passing [Ok value]. In case of
        failure, [Error error_code] is passed, and [error_code] is guaranteed
        not to be {!Luv.Error.success}. It will be one of the other {{!codes}
        error codes}.
      }
    } *)
(* TODO DOC Hide the definition in the rendered docs. *)

val strerror : t -> string
(** Returns the error message corresponding to the given error code. Binding to
    {{:http://docs.libuv.org/en/v1.x/errors.html#c.uv_strerror_r}
    [uv_strerror_r]}. *)

val err_name : t -> string
(** Returns the name of the given error code. Binding to
    {{:http://docs.libuv.org/en/v1.x/errors.html#c.uv_err_name_r}
    [uv_err_name_r]}. *)

val translate_sys_error : int -> t
(** Converts a system error code to a libuv error code. See
    {{:http://docs.libuv.org/en/v1.x/errors.html#c.uv_translate_sys_error}
    [uv_translate_sys_error]}. *)



(** {1 User exception handler} *)

val set_on_unhandled_exception : (exn -> unit) -> unit
(** If your code terminates a callback by raising an exception, the exception
    cannot be allowed to go up the call stack, because the callback was called
    by libuv (rather than OCaml code). Luv instead passes the exception to a
    global Luv exception handler. [Luv.Error.set_on_unhandled_exception f]
    replaces this exception handler with [f].

    For example, in

    {[
      Luv.Error.set_on_unhandled_exception f;
      Luv.File.Async.mkdir "foo" (fun _ -> raise Exit);
    ]}

    the exception [Exit] is passed to [f] when [mkdir] calls its callback.

    It is recommended to avoid letting exceptions escape from callbacks in this
    way.

    Note, again, that Luv does not raise any exceptions of its own.

    The default behavior, if [set_on_unhandled_exception] is never called, is
    for Luv to print the exception to STDERR and exit the process with exit code
    2.

    It is recommended not to call [set_on_unhandled_exception] from libraries
    based on Luv, but, instead, to leave the decision on how to handle
    exceptions up to the final application. *)



(** {1:codes Error code values}

    Except for [success], these are bindings to the
    {{:http://docs.libuv.org/en/v1.x/errors.html#error-constants} constants
    defined by libuv}, which take after Unix error codes (see
    {{:http://man7.org/linux/man-pages/man3/errno.3.html} [errno(3)], section {i
    List of error names}}).

    [success] is bound to the constant [0], which is used throughout
    libuv to indicate “no error.” *)



(**/**)

val from_c : int -> t
val result_from_c : int -> (_, t) result
val to_result : 'a -> int -> ('a, t) result
val to_result_lazy : (unit -> 'a) -> int -> ('a, t) result
val clamp : int -> int

(* TODO Don't catch exceptions in synchronous callbacks. *)
val catch_exceptions : ('a -> unit) -> ('a -> unit)
val unhandled_exception : exn -> unit
