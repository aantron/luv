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
  | `ENODATA
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
  | `EOVERFLOW
  | `EPERM
  | `EPIPE
  | `EPROTO
  | `EPROTONOSUPPORT
  | `EPROTOTYPE
  | `ERANGE
  | `EROFS
  | `ESHUTDOWN
  | `ESOCKTNOSUPPORT
  | `ESPIPE
  | `ESRCH
  | `ETIMEDOUT
  | `ETXTBSY
  | `EUNATCH
  | `EXDEV
  | `UNKNOWN
  | `EOF
  | `ENXIO
  | `EMLINK
]

let to_c = let open C.Types.Error in function
  | `E2BIG -> e2big
  | `EACCES -> eacces
  | `EADDRINUSE -> eaddrinuse
  | `EADDRNOTAVAIL -> eaddrnotavail
  | `EAFNOSUPPORT -> eafnosupport
  | `EAGAIN -> eagain
  | `EAI_ADDRFAMILY -> eai_addrfamily
  | `EAI_AGAIN -> eai_again
  | `EAI_BADFLAGS -> eai_badflags
  | `EAI_BADHINTS -> eai_badhints
  | `EAI_CANCELED -> eai_canceled
  | `EAI_FAIL -> eai_fail
  | `EAI_FAMILY -> eai_family
  | `EAI_MEMORY -> eai_memory
  | `EAI_NODATA -> eai_nodata
  | `EAI_NONAME -> eai_noname
  | `EAI_OVERFLOW -> eai_overflow
  | `EAI_PROTOCOL -> eai_protocol
  | `EAI_SERVICE -> eai_service
  | `EAI_SOCKTYPE -> eai_socktype
  | `EALREADY -> ealready
  | `EBADF -> ebadf
  | `EBUSY -> ebusy
  | `ECANCELED -> ecanceled
  | `ECONNABORTED -> econnaborted
  | `ECONNREFUSED -> econnrefused
  | `ECONNRESET -> econnreset
  | `EDESTADDRREQ -> edestaddrreq
  | `EEXIST -> eexist
  | `EFAULT -> efault
  | `EFBIG -> efbig
  | `EFTYPE -> eftype
  | `EHOSTUNREACH -> ehostunreach
  | `EILSEQ -> eilseq
  | `EINTR -> eintr
  | `EINVAL -> einval
  | `EIO -> eio
  | `EISCONN -> eisconn
  | `EISDIR -> eisdir
  | `ELOOP -> eloop
  | `EMFILE -> emfile
  | `EMSGSIZE -> emsgsize
  | `ENAMETOOLONG -> enametoolong
  | `ENETDOWN -> enetdown
  | `ENETUNREACH -> enetunreach
  | `ENFILE -> enfile
  | `ENOBUFS -> enobufs
  | `ENODATA -> enodata
  | `ENODEV -> enodev
  | `ENOENT -> enoent
  | `ENOMEM -> enomem
  | `ENONET -> enonet
  | `ENOPROTOOPT -> enoprotoopt
  | `ENOSPC -> enospc
  | `ENOSYS -> enosys
  | `ENOTCONN -> enotconn
  | `ENOTDIR -> enotdir
  | `ENOTEMPTY -> enotempty
  | `ENOTSOCK -> enotsock
  | `ENOTSUP -> enotsup
  | `ENOTTY -> enotty
  | `EOVERFLOW -> eoverflow
  | `EPERM -> eperm
  | `EPIPE -> epipe
  | `EPROTO -> eproto
  | `EPROTONOSUPPORT -> eprotonosupport
  | `EPROTOTYPE -> eprototype
  | `ERANGE -> erange
  | `EROFS -> erofs
  | `ESHUTDOWN -> eshutdown
  | `ESOCKTNOSUPPORT -> esocktnosupport
  | `ESPIPE -> espipe
  | `ESRCH -> esrch
  | `ETIMEDOUT -> etimedout
  | `ETXTBSY -> etxtbsy
  | `EUNATCH -> eunatch
  | `EXDEV -> exdev
  | `UNKNOWN -> unknown
  | `EOF -> eof
  | `ENXIO -> enxio
  | `EMLINK -> emlink

let from_c = let open C.Types.Error in function
  | e when e = e2big -> `E2BIG
  | e when e = eacces -> `EACCES
  | e when e = eaddrinuse -> `EADDRINUSE
  | e when e = eaddrnotavail -> `EADDRNOTAVAIL
  | e when e = eafnosupport -> `EAFNOSUPPORT
  | e when e = eagain -> `EAGAIN
  | e when e = eai_addrfamily -> `EAI_ADDRFAMILY
  | e when e = eai_again -> `EAI_AGAIN
  | e when e = eai_badflags -> `EAI_BADFLAGS
  | e when e = eai_badhints -> `EAI_BADHINTS
  | e when e = eai_canceled -> `EAI_CANCELED
  | e when e = eai_fail -> `EAI_FAIL
  | e when e = eai_family -> `EAI_FAMILY
  | e when e = eai_memory -> `EAI_MEMORY
  | e when e = eai_nodata -> `EAI_NODATA
  | e when e = eai_noname -> `EAI_NONAME
  | e when e = eai_overflow -> `EAI_OVERFLOW
  | e when e = eai_protocol -> `EAI_PROTOCOL
  | e when e = eai_service -> `EAI_SERVICE
  | e when e = eai_socktype -> `EAI_SOCKTYPE
  | e when e = ealready -> `EALREADY
  | e when e = ebadf -> `EBADF
  | e when e = ebusy -> `EBUSY
  | e when e = ecanceled -> `ECANCELED
  | e when e = econnaborted -> `ECONNABORTED
  | e when e = econnrefused -> `ECONNREFUSED
  | e when e = econnreset -> `ECONNRESET
  | e when e = edestaddrreq -> `EDESTADDRREQ
  | e when e = eexist -> `EEXIST
  | e when e = efault -> `EFAULT
  | e when e = efbig -> `EFBIG
  | e when e = eftype -> `EFTYPE
  | e when e = ehostunreach -> `EHOSTUNREACH
  | e when e = eilseq -> `EILSEQ
  | e when e = eintr -> `EINTR
  | e when e = einval -> `EINVAL
  | e when e = eio -> `EIO
  | e when e = eisconn -> `EISCONN
  | e when e = eisdir -> `EISDIR
  | e when e = eloop -> `ELOOP
  | e when e = emfile -> `EMFILE
  | e when e = emsgsize -> `EMSGSIZE
  | e when e = enametoolong -> `ENAMETOOLONG
  | e when e = enetdown -> `ENETDOWN
  | e when e = enetunreach -> `ENETUNREACH
  | e when e = enfile -> `ENFILE
  | e when e = enobufs -> `ENOBUFS
  | e when e = enodev -> `ENODEV
  | e when e = enoent -> `ENOENT
  | e when e = enomem -> `ENOMEM
  | e when e = enonet -> `ENONET
  | e when e = enoprotoopt -> `ENOPROTOOPT
  | e when e = enospc -> `ENOSPC
  | e when e = enosys -> `ENOSYS
  | e when e = enotconn -> `ENOTCONN
  | e when e = enotdir -> `ENOTDIR
  | e when e = enotempty -> `ENOTEMPTY
  | e when e = enotsock -> `ENOTSOCK
  | e when e = enotsup -> `ENOTSUP
  | e when e = enotty -> `ENOTTY
  | e when e = eoverflow -> `EOVERFLOW
  | e when e = eperm -> `EPERM
  | e when e = epipe -> `EPIPE
  | e when e = eproto -> `EPROTO
  | e when e = eprotonosupport -> `EPROTONOSUPPORT
  | e when e = eprototype -> `EPROTOTYPE
  | e when e = erange -> `ERANGE
  | e when e = erofs -> `EROFS
  | e when e = eshutdown -> `ESHUTDOWN
  | e when e = esocktnosupport -> `ESOCKTNOSUPPORT
  | e when e = espipe -> `ESPIPE
  | e when e = esrch -> `ESRCH
  | e when e = etimedout -> `ETIMEDOUT
  | e when e = etxtbsy -> `ETXTBSY
  | e when e = exdev -> `EXDEV
  | e when e = unknown -> `UNKNOWN
  | e when e = eof -> `EOF
  | e when e = enxio -> `ENXIO
  | e when e = emlink -> `EMLINK
  | _ -> `UNKNOWN

let result_from_c error_code =
  Error (from_c error_code)

let translate_sys_error sys_error_code =
  C.Functions.Error.translate_sys_error sys_error_code
  |> from_c

let error_string_generic c_function error =
  let length = 256 in
  let buffer = Bytes.create length in
  c_function
    (to_c error) (Ctypes.ocaml_bytes_start buffer) length;
  let length = Bytes.index buffer '\000' in
  Bytes.sub_string buffer 0 length

let strerror =
  error_string_generic C.Functions.Error.strerror_r

let err_name =
  error_string_generic C.Functions.Error.err_name_r

let exception_handler =
  ref begin fun exn ->
    prerr_endline (Printexc.to_string exn);
    Printexc.print_backtrace stderr;
    exit 2
  end

let set_on_unhandled_exception f =
  exception_handler := f

let unhandled_exception exn =
  !exception_handler exn

let catch_exceptions f v =
  try
    f v
  with exn ->
    unhandled_exception exn

let to_result success_value error_code =
  if error_code >= 0 then
    Ok success_value
  else
    Error (from_c error_code)

let to_result_lazy get_success_value error_code =
  if error_code >= 0 then
    Ok (get_success_value ())
  else
    Error (from_c error_code)

let clamp code =
  if code >= 0 then
    0
  else
    code
