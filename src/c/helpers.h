// This file is part of Luv, released under the MIT license. See LICENSE.md for
// details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md.



#pragma once

#ifndef LUV_HELPERS_H_
#define LUV_HELPERS_H_

#ifndef _WIN32
#include <unistd.h>
#endif

#include <caml/mlvalues.h>
#include <uv.h>
#include "shims.h"



#ifdef _WIN32
#ifndef S_ISUID
#define S_ISUID 0
#endif
#ifndef S_ISGID
#define S_ISGID 0
#endif
#ifndef S_ISVTX
#define S_ISVTX 0
#endif
#ifndef SIGPROF
#define SIGPROF 0
#endif
typedef ADDRESS_FAMILY sa_family_t;
#endif



// Callback trampolines.
//
// We need to pass C function pointers to libuv, but call OCaml callbacks.
// Trampolines are the C functions whose addresses are passed to libuv, and all
// they do is retrieve the correct OCaml callback from the handle or request
// that is passed to them by libuv, and call it.

// Not declared by libuv.
typedef void (*luv_once_cb)(void);

// Differ from libuv declarations in const-ness of arguments. See "Warning
// suppression" below.
typedef void (*luv_fs_event_cb)(
    uv_fs_event_t *handle, char *filename, int events, int status);

typedef void (*luv_fs_poll_cb)(
    uv_fs_poll_t *handle, int status, uv_stat_t *prev, uv_stat_t *curr);

typedef void (*luv_getnameinfo_cb)(
    uv_getnameinfo_t *req, int status, char *hostname, char *service);

typedef void (*luv_read_cb)(uv_stream_t *stream, ssize_t nread, uv_buf_t *buf);

typedef void (*luv_udp_recv_cb)(
    uv_udp_t *handle, ssize_t nread, uv_buf_t *buf, struct sockaddr *addr,
    unsigned int flags);

uv_after_work_cb luv_get_after_work_trampoline(void);
uv_alloc_cb luv_get_alloc_trampoline(void);
uv_async_cb luv_get_async_trampoline(void);
uv_check_cb luv_get_check_trampoline(void);
uv_close_cb luv_get_close_trampoline(void);
uv_connect_cb luv_get_connect_trampoline(void);
uv_connection_cb luv_get_connection_trampoline(void);
uv_exit_cb luv_get_exit_trampoline(void);
uv_exit_cb luv_null_exit_trampoline(void);
uv_fs_cb luv_get_fs_trampoline(void);
uv_fs_cb luv_null_fs_callback_pointer(void);
luv_fs_event_cb luv_get_fs_event_trampoline(void);
luv_fs_poll_cb luv_get_fs_poll_trampoline(void);
uv_getaddrinfo_cb luv_get_getaddrinfo_trampoline(void);
luv_getnameinfo_cb luv_get_getnameinfo_trampoline(void);
uv_idle_cb luv_get_idle_trampoline(void);
luv_once_cb luv_get_once_trampoline(void);
uv_poll_cb luv_get_poll_trampoline(void);
uv_prepare_cb luv_get_prepare_trampoline(void);
uv_random_cb luv_get_random_trampoline(void);
uv_random_cb luv_null_random_trampoline(void);
luv_read_cb luv_get_read_trampoline(void);
luv_udp_recv_cb luv_get_recv_trampoline(void);
uv_udp_send_cb luv_get_send_trampoline(void);
uv_shutdown_cb luv_get_shutdown_trampoline(void);
uv_signal_cb luv_get_signal_trampoline(void);
uv_thread_cb luv_get_thread_trampoline(void);
uv_timer_cb luv_get_timer_trampoline(void);
uv_work_cb luv_get_work_trampoline(void);
uv_write_cb luv_get_write_trampoline(void);

// Handles can have multiple outstanding callbacks, so the corresponding OCaml
// closures are stored in an array. These are the indices into that array for
// the various callbacks.

// All handles and requests have at least a self-reference, and a reference to
// an OCaml callback.
enum {
    LUV_SELF_REFERENCE,
    LUV_GENERIC_CALLBACK,
    LUV_MINIMUM_REFERENCE_COUNT
};

// Handles additionally have a reference to an OCaml close callback.
enum {
    LUV_CLOSE_CALLBACK = LUV_MINIMUM_REFERENCE_COUNT,
    LUV_HANDLE_REFERENCE_COUNT
};

// Stream handles have additional callbacks.
enum {
    LUV_ALLOCATE_CALLBACK = LUV_HANDLE_REFERENCE_COUNT,
    LUV_CONNECTION_CALLBACK,
    LUV_STREAM_REFERENCE_COUNT
};

// UDP handles have other additional callbacks.
enum {
    LUV_UDP_ALLOCATE_CALLBACK = LUV_HANDLE_REFERENCE_COUNT,
    LUV_UDP_REFERENCE_COUNT
};

// Thread pool requests store one extra callback over normal requests.
enum {
    LUV_WORK_FUNCTION = LUV_MINIMUM_REFERENCE_COUNT,
    LUV_WORK_REFERENCE_COUNT
};



// Helpers for setting up uv_queue_work requests that call a C function.
int luv_add_c_function_and_argument(
    uv_work_t *c_request, intnat function, intnat argument);
uv_after_work_cb luv_get_after_c_work_trampoline(void);
uv_work_cb luv_get_c_work_trampoline(void);

// Helper for calling uv_thread_create with the address of a C function.
int luv_thread_create_c(
    uv_thread_t *tid,
    const uv_thread_options_t* options,
    intnat entry,
    intnat arg);

// Helpers for uv_once.
int luv_once_init(uv_once_t *guard);
CAMLprim value luv_set_once_callback(value callback);



// Warning suppression.
//
// These wrappers just call the functions they wrap, but the arguments and/or
// return values have different const-ness from how they are declared by libuv.
// Ctypes is unable to emit the correct cv-qualifiers, so binding the libuv
// functions directly with Ctypes results in noisy warnings. These wrappers
// suppress the warnings by performing const_casts.
char* luv_version_string(void);
char* luv_req_type_name(uv_req_type type);
char* luv_fs_get_path(const uv_fs_t *req);
char* luv_dlerror(const uv_lib_t *lib);

int luv_fs_event_start(
    uv_fs_event_t *handle, luv_fs_event_cb cb, const char *path,
    unsigned int flags);

int luv_fs_poll_start(
    uv_fs_poll_t *handle, luv_fs_poll_cb poll_cb, const char *path,
    unsigned int interval);

int luv_getnameinfo(
    uv_loop_t *loop, uv_getnameinfo_t *req, luv_getnameinfo_cb getnameinfo_cb,
    const struct sockaddr *addr, int flags);

int luv_read_start(
    uv_stream_t *stream, uv_alloc_cb alloc_cb, luv_read_cb read_cb);

int luv_udp_recv_start(
    uv_udp_t *handle, uv_alloc_cb alloc_cb, luv_udp_recv_cb recv_cb);

// Helper for uv_os_uname, which uses an inconvenient buffer argument type.
int luv_os_uname(char *buffer);



// Miscellaneous helpers - other things that are easiest to do in C.

// Ctypes.constant can't bind a char*, so we return it instead.
char* luv_version_suffix(void);

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

// File descriptor validity checks. These are used only by Luv.Unix. However,
// because they are exposed in OCaml through Ctypes, it is convenient to have
// them here. They don't introduce a dependency on Unix. THe rest of the file
// descriptor C helpers, which do depend on Unix, are defined in Luv.Unix's own
// C helper file. Conveniently, they are, and must be, exposed in OCaml through
// the built-in FFI.
int luv_is_invalid_handle_value(uv_os_fd_t handle);
int luv_is_invalid_socket_value(uv_os_sock_t socket);

// sa_family_t has different size on different platforms, so we use a helper for
// casting it to an int on the C side. See
//   https://github.com/aantron/luv/pull/112
int luv_sa_family_to_int(sa_family_t family);



#endif // #ifndef LUV_HELPERS_H_
