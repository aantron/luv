// This file is part of Luv, released under the MIT license. See LICENSE.md for
// details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md.



#define CAML_NAME_SPACE
#include <caml/mlvalues.h>
#include <caml/unixsupport.h>
#include <uv.h>



CAMLprim value luv_unix_fd_to_os_fd(value unix_fd, value os_fd_storage)
{
    uv_os_fd_t *os_fd = (uv_os_fd_t*)Nativeint_val(os_fd_storage);

#ifndef _WIN32
    *os_fd = Int_val(unix_fd);
#else
    if (Descr_kind_val(unix_fd) == KIND_HANDLE)
        *os_fd = Handle_val(unix_fd);
    else
        *os_fd = -1;
#endif

    return Val_unit;
}

CAMLprim value luv_unix_fd_to_os_socket(value unix_fd, value os_socket_storage)
{
    uv_os_sock_t *os_socket = (uv_os_sock_t*)Nativeint_val(os_socket_storage);

#ifndef _WIN32
    *os_socket = Int_val(unix_fd);
#else
    if (Descr_kind_val(unix_fd) == KIND_SOCKET)
        *os_socket = Handle_val(unix_fd);
    else
        *os_socket = -1;
#endif

    return Val_unit;
}

CAMLprim value luv_os_fd_to_unix_fd(value os_fd_storage)
{
    uv_os_fd_t *os_fd = (uv_os_fd_t*)Nativeint_val(os_fd_storage);

#ifndef _WIN32
    return Val_int(*os_fd);
#else
    return win_alloc_handle(*os_fd);
#endif
}

CAMLprim value luv_os_socket_to_unix_fd(value os_socket_storage)
{
    uv_os_sock_t *os_socket = (uv_os_sock_t*)Nativeint_val(os_socket_storage);

#ifndef _WIN32
    return Val_int(*os_socket);
#else
    return win_alloc_socket(*os_socket);
#endif
}
