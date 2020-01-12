let errors = [
  "UV_E2BIG";
  "UV_EACCES";
  "UV_EADDRINUSE";
  "UV_EADDRNOTAVAIL";
  "UV_EAFNOSUPPORT";
  "UV_EAGAIN";
  "UV_EAI_ADDRFAMILY";
  "UV_EAI_AGAIN";
  "UV_EAI_BADFLAGS";
  "UV_EAI_BADHINTS";
  "UV_EAI_CANCELED";
  "UV_EAI_FAIL";
  "UV_EAI_FAMILY";
  "UV_EAI_MEMORY";
  "UV_EAI_NODATA";
  "UV_EAI_NONAME";
  "UV_EAI_OVERFLOW";
  "UV_EAI_PROTOCOL";
  "UV_EAI_SERVICE";
  "UV_EAI_SOCKTYPE";
  "UV_EALREADY";
  "UV_EBADF";
  "UV_EBUSY";
  "UV_ECANCELED";
  "UV_ECONNABORTED";
  "UV_ECONNREFUSED";
  "UV_ECONNRESET";
  "UV_EDESTADDRREQ";
  "UV_EEXIST";
  "UV_EFAULT";
  "UV_EFBIG";
  "UV_EHOSTUNREACH";
  "UV_EILSEQ";
  "UV_EINTR";
  "UV_EINVAL";
  "UV_EIO";
  "UV_EISCONN";
  "UV_EISDIR";
  "UV_ELOOP";
  "UV_EMFILE";
  "UV_EMSGSIZE";
  "UV_ENAMETOOLONG";
  "UV_ENETDOWN";
  "UV_ENETUNREACH";
  "UV_ENFILE";
  "UV_ENOBUFS";
  "UV_ENODEV";
  "UV_ENOENT";
  "UV_ENOMEM";
  "UV_ENONET";
  "UV_ENOPROTOOPT";
  "UV_ENOSPC";
  "UV_ENOSYS";
  "UV_ENOTCONN";
  "UV_ENOTDIR";
  "UV_ENOTEMPTY";
  "UV_ENOTSOCK";
  "UV_ENOTSUP";
  "UV_EPERM";
  "UV_EPIPE";
  "UV_EPROTO";
  "UV_EPROTONOSUPPORT";
  "UV_EPROTOTYPE";
  "UV_ERANGE";
  "UV_EROFS";
  "UV_ESHUTDOWN";
  "UV_ESPIPE";
  "UV_ESRCH";
  "UV_ETIMEDOUT";
  "UV_ETXTBSY";
  "UV_EXDEV";
  "UV_UNKNOWN";
  "UV_EOF";
  "UV_ENXIO";
  "UV_EMLINK";
]

let luv_name name =
  if String.length name < 4 then
    name
  else
    if String.sub name 0 3 = "UV_" then
      String.sub name 3 (String.length name - 3)
    else
      name

let from_c () =
  errors
  |> List.map luv_name
  |> List.map (fun name ->
    Printf.sprintf
      "  | e when e = %s -> `%s" (String.lowercase_ascii name) name)
  |> List.iter print_endline

let to_c () =
  errors
  |> List.map luv_name
  |> List.map (fun name ->
    Printf.sprintf
      "  | `%s -> %s" name (String.lowercase_ascii name))
  |> List.iter print_endline

let () =
  to_c ()
