#include <stdlib.h>

#define CAML_NAME_SPACE
#include <caml/bigarray.h>
#include <caml/callback.h>
#include <caml/mlvalues.h>
#include <caml/socketaddr.h>
#include "ctypes_cstubs_internals.h"

#include <uv.h>
#include "helpers.h"



// TODO Deal with the runtime system lock. Do we need to take it before calling
// a callback?

// Handle trampolines.

// CAMLlocal is (probably?) not needed here, because there is already a gc root
// pointing to the callback.
#define GET_HANDLE_CALLBACK(callback_index) \
    value *gc_root = uv_handle_get_data((uv_handle_t*)c_handle); \
    value ocaml_handle = *gc_root; \
    value callback_table = Field(ocaml_handle, 0); \
    value callback = Field(callback_table, callback_index);

static void luv_alloc_trampoline(
    uv_handle_t *c_handle, size_t suggested_size, uv_buf_t *buffer)
{
    GET_HANDLE_CALLBACK(LUV_ALLOCATE_CALLBACK_INDEX);

    value bigstring =
        caml_callback2(callback, ocaml_handle, Val_int((int)suggested_size));

    buffer->base = Caml_ba_data_val(bigstring);
    buffer->len = Caml_ba_array_val(bigstring)->dim[0];
}

static void luv_async_trampoline(uv_async_t *c_handle)
{
    GET_HANDLE_CALLBACK(LUV_HANDLE_GENERIC_CALLBACK_INDEX);
    caml_callback(callback, ocaml_handle);
}

static void luv_check_trampoline(uv_check_t *c_handle)
{
    GET_HANDLE_CALLBACK(LUV_HANDLE_GENERIC_CALLBACK_INDEX);
    caml_callback(callback, ocaml_handle);
}

static void luv_close_trampoline(uv_handle_t *c_handle)
{
    GET_HANDLE_CALLBACK(LUV_HANDLE_GENERIC_CALLBACK_INDEX);
    caml_callback(callback, ocaml_handle);
}

static void luv_connection_trampoline(uv_stream_t *c_handle, int status)
{
    GET_HANDLE_CALLBACK(LUV_CONNECTION_CALLBACK_INDEX);
    caml_callback2(callback, ocaml_handle, Val_int(status));
}

static void luv_exit_trampoline(
    uv_process_t *c_handle, int64_t exit_status, int term_signal)
{
    GET_HANDLE_CALLBACK(LUV_HANDLE_GENERIC_CALLBACK_INDEX);
    caml_callback3(
        callback, ocaml_handle, Val_int(exit_status), Val_int(term_signal));
}

static void luv_idle_trampoline(uv_idle_t *c_handle)
{
    GET_HANDLE_CALLBACK(LUV_HANDLE_GENERIC_CALLBACK_INDEX);
    caml_callback(callback, ocaml_handle);
}

static void luv_poll_trampoline(uv_poll_t *c_handle, int status, int event)
{
    GET_HANDLE_CALLBACK(LUV_HANDLE_GENERIC_CALLBACK_INDEX);
    caml_callback3(callback, ocaml_handle, Val_int(status), Val_int(event));
}

static void luv_prepare_trampoline(uv_prepare_t *c_handle)
{
    GET_HANDLE_CALLBACK(LUV_HANDLE_GENERIC_CALLBACK_INDEX);
    caml_callback(callback, ocaml_handle);
}

static void luv_read_trampoline(
    uv_stream_t *c_handle, ssize_t nread, uv_buf_t *buffer)
{
    GET_HANDLE_CALLBACK(LUV_READ_CALLBACK_INDEX);
    caml_callback2(callback, ocaml_handle, Val_int((int)nread));
}

static void luv_signal_trampoline(uv_signal_t *c_handle, int signum)
{
    GET_HANDLE_CALLBACK(LUV_HANDLE_GENERIC_CALLBACK_INDEX);
    caml_callback2(callback, ocaml_handle, Val_int(signum));
}

static void luv_timer_trampoline(uv_timer_t *c_handle)
{
    GET_HANDLE_CALLBACK(LUV_HANDLE_GENERIC_CALLBACK_INDEX);
    caml_callback(callback, ocaml_handle);
}

uv_alloc_cb luv_address_of_alloc_trampoline()
{
    return luv_alloc_trampoline;
}

uv_async_cb luv_address_of_async_trampoline()
{
    return luv_async_trampoline;
}

uv_check_cb luv_address_of_check_trampoline()
{
    return luv_check_trampoline;
}

uv_close_cb luv_address_of_close_trampoline()
{
    return luv_close_trampoline;
}

uv_connection_cb luv_address_of_connection_trampoline()
{
    return luv_connection_trampoline;
}

uv_exit_cb luv_address_of_exit_trampoline()
{
    return luv_exit_trampoline;
}

uv_exit_cb luv_null_exit_trampoline()
{
    return NULL;
}

uv_idle_cb luv_address_of_idle_trampoline()
{
    return luv_idle_trampoline;
}

uv_poll_cb luv_address_of_poll_trampoline()
{
    return luv_poll_trampoline;
}

uv_prepare_cb luv_address_of_prepare_trampoline()
{
    return luv_prepare_trampoline;
}

luv_read_cb luv_address_of_read_trampoline()
{
    return luv_read_trampoline;
}

uv_signal_cb luv_address_of_signal_trampoline()
{
    return luv_signal_trampoline;
}

uv_timer_cb luv_address_of_timer_trampoline()
{
    return luv_timer_trampoline;
}



// Request trampolines.

#define GET_REQUEST_CALLBACK() \
    value *gc_root = uv_req_get_data((uv_req_t*)c_request); \
    value callback = *gc_root;

static void luv_connect_trampoline(uv_connect_t *c_request, int status)
{
    GET_REQUEST_CALLBACK();
    caml_callback(callback, Val_int(status));
}

static void luv_fs_request_trampoline(uv_fs_t *c_request)
{
    GET_REQUEST_CALLBACK();
    caml_callback(callback, Val_unit);
}

static void luv_shutdown_trampoline(uv_shutdown_t *c_request, int status)
{
    GET_REQUEST_CALLBACK();
    caml_callback(callback, Val_int(status));
}

static void luv_write_trampoline(uv_write_t *c_request, int status)
{
    GET_REQUEST_CALLBACK();
    caml_callback(callback, Val_int(status));
}

uv_connect_cb luv_address_of_connect_trampoline()
{
    return luv_connect_trampoline;
}

uv_fs_cb luv_address_of_fs_trampoline()
{
    return luv_fs_request_trampoline;
}

uv_fs_cb luv_null_fs_callback_pointer()
{
    return NULL;
}

uv_write_cb luv_address_of_write_trampoline()
{
    return luv_write_trampoline;
}

uv_shutdown_cb luv_address_of_shutdown_trampoline()
{
    return luv_shutdown_trampoline;
}



// Warning-suppressing wrappers.

char* luv_strerror(int err)
{
    return (char*)uv_strerror(err);
}

char* luv_err_name(int err)
{
    return (char*)uv_err_name(err);
}

char* luv_version_string()
{
    return (char*)uv_version_string();
}

char* luv_req_type_name(uv_req_type type)
{
    return (char*)uv_req_type_name(type);
}

char* luv_fs_get_path(const uv_fs_t *req)
{
    return (char*)uv_fs_get_path(req);
}

int luv_read_start(
    uv_stream_t *stream, uv_alloc_cb alloc_cb, luv_read_cb read_cb)
{
    return uv_read_start(stream, alloc_cb, (uv_read_cb)read_cb);
}



// Other helpers.

uv_buf_t* luv_bigstrings_to_iovecs(char **pointers, int *lengths, int count)
{
    // TODO Error handling?
    uv_buf_t *iovecs = malloc(sizeof(uv_buf_t) * count);

    for (int index = 0; index < count; ++index)
        iovecs[index] = uv_buf_init(pointers[index], lengths[index]);

    return iovecs;
}

CAMLprim value luv_get_sockaddr(value ocaml_sockaddr, value c_storage)
{
    socklen_param_type length;
    union sock_addr_union *c_sockaddr =
        (union sock_addr_union*)Nativeint_val(c_storage);

    get_sockaddr(ocaml_sockaddr, c_sockaddr, &length);

    return Val_int(length);
}

CAMLprim value luv_alloc_sockaddr(value c_storage, value length)
{
    union sock_addr_union *c_sockaddr =
        (union sock_addr_union*)Nativeint_val(c_storage);

    return alloc_sockaddr(c_sockaddr, Int_val(length), -1);
}

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
    int gid)
{
    args[arg_count] = NULL;

    if (set_env)
        env[env_count] = NULL;
    else
        env = NULL;

    if (do_cwd == 0)
        cwd = NULL;

    uv_process_options_t options;
    options.exit_cb = exit_cb;
    options.file = file;
    options.args = args;
    options.env = env;
    options.cwd = cwd;
    options.flags = flags;
    options.stdio_count = stdio_count;
    options.stdio = stdio;
    options.uid = uid;
    options.gid = gid;

    int result = uv_spawn(loop, handle, &options);

    return result;
}
