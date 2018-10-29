#pragma once

#ifndef LUV_HELPERS_H_
#define LUV_HELPERS_H_

#include <caml/mlvalues.h>
#include <uv.h>



// Callback trampolines.
//
// We need to pass C function pointers to libuv, but call OCaml callbacks.
// Trampolines are the C functions whose addresses are passed to libuv, and all
// they do is retrieve the correct OCaml callback from the handle or request
// that is passed to them by libuv, and call it.

uv_after_work_cb luv_address_of_after_work_trampoline();
uv_alloc_cb luv_address_of_alloc_trampoline();
uv_async_cb luv_address_of_async_trampoline();
uv_check_cb luv_address_of_check_trampoline();
uv_close_cb luv_address_of_close_trampoline();
uv_connect_cb luv_address_of_connect_trampoline();
uv_connection_cb luv_address_of_connection_trampoline();
uv_exit_cb luv_address_of_exit_trampoline();
uv_exit_cb luv_null_exit_trampoline();
uv_fs_cb luv_address_of_fs_trampoline();
uv_fs_cb luv_null_fs_callback_pointer();
uv_idle_cb luv_address_of_idle_trampoline();
uv_poll_cb luv_address_of_poll_trampoline();
uv_prepare_cb luv_address_of_prepare_trampoline();
uv_shutdown_cb luv_address_of_shutdown_trampoline();
uv_signal_cb luv_address_of_signal_trampoline();
uv_timer_cb luv_address_of_timer_trampoline();
uv_work_cb luv_address_of_work_trampoline();
uv_write_cb luv_address_of_write_trampoline();

// Handles can have multiple outstanding callbacks, so the corresponding OCaml
// closures are stored in an array. These are the indices into that array for
// the various callbacks.

// TODO Create a separate slot for close callbacks.
enum {
    LUV_SELF_REFERENCE,
    LUV_GENERIC_CALLBACK,
    LUV_MINIMUM_REFERENCE_COUNT
};

enum {
    LUV_CONNECTION_CALLBACK = LUV_MINIMUM_REFERENCE_COUNT,
    LUV_READ_CALLBACK,
    LUV_ALLOCATE_CALLBACK,
    LUV_STREAM_REFERENCE_COUNT
};

enum {
    LUV_WORK_FUNCTION = LUV_MINIMUM_REFERENCE_COUNT,
    LUV_WORK_REFERENCE_COUNT
};



// Helpers for setting up uv_queue_work requests that call a C function.
int luv_add_c_function_and_argument(
    uv_work_t *c_request, intnat function, intnat argument);
uv_after_work_cb luv_address_of_after_c_work_trampoline();
uv_work_cb luv_address_of_c_work_trampoline();



// Warning suppression.
//
// These wrappers just call the functions they wrap, but the arguments and/or
// return values have different const-ness from how they are declared by libuv.
// Ctypes is unable to emit the correct cv-qualifiers, so binding the libuv
// functions directly with Ctypes results in noisy warnings. These wrappers
// suppress the warnings by performing const_casts.
char* luv_strerror(int err);
char* luv_version_string();
char* luv_req_type_name(uv_req_type type);
char* luv_fs_get_path(const uv_fs_t *req);

typedef void (*luv_read_cb)(uv_stream_t *stream, ssize_t nread, uv_buf_t *buf);
luv_read_cb luv_address_of_read_trampoline();
int luv_read_start(
    uv_stream_t *stream, uv_alloc_cb alloc_cb, luv_read_cb read_cb);



// File descriptor plumbing. The different operating systems have different
// kinds of file descriptors. libuv, meanwhile, uses CRT file descriptors. THese
// coincide with Unix system fds, but not Windows. In addition, there is
// Unix.file_descr. These helpers are used for converting between all these
// types in a relatively safe way.
int luv_is_invalid_handle_value(uv_os_fd_t handle);
CAMLprim value luv_unix_fd_to_os_fd(value unix_fd, value os_fd_storage);
CAMLprim value luv_os_fd_to_unix_fd(value os_fd_storage);
int luv_is_invalid_socket_value(uv_os_sock_t socket);
CAMLprim value luv_unix_fd_to_os_socket(value unix_fd, value os_socket_storage);
CAMLprim value luv_os_socket_to_unix_fd(value os_socket_storage);



// Miscellaneous helpers - other things that are easiest to do in C.

// Ctypes.constant can't bind a char*, so we return it instead.
char* luv_version_suffix();

// The OCaml runtime has helpers for converting between Unix.sockaddr and the
// system's sockaddr structures. However, the arguments and return values are a
// mixture of C and OCaml values, and Ctypes is not able to bind to them. See
//   https://github.com/ocamllabs/ocaml-ctypes/pull/569
// So, we create wrappers, and bind to the wrappers using the vanilla FFI.
CAMLprim value luv_get_sockaddr(value ocaml_sockaddr, value c_storage);
CAMLprim value luv_alloc_sockaddr(value c_storage, value length);

// The arguments to uv_spawn involve complex-enough C data, that it is easiest
// to create a wrapper function that takes simple arguments, and create the
// proper argument data structures in C.
int luv_spawn(
    uv_loop_t *loop,
    uv_process_t *handle,
    uv_exit_cb exit_cb,
    const char *file,
    char **args,
    int arg_count,
    char **env,
    int env_count,
    int set_env,
    const char *cwd,
    int do_cwd,
    int flags,
    int stdio_count,
    uv_stdio_container_t *stdio,
    int uid,
    int gid);



#endif // #ifndef LUV_HELPERS_H_
