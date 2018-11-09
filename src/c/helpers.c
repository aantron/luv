#include <stdlib.h>

#define CAML_NAME_SPACE
#include <caml/bigarray.h>
#include <caml/callback.h>
#include <caml/mlvalues.h>
#include <caml/socketaddr.h>
#include "ctypes_cstubs_internals.h"

#include <uv.h>
#include "helpers.h"



// Trampolines.

// CAMLlocal is (probably?) not needed here, because there is already a gc root
// pointing to the callback.
#define GET_REFERENCES(callback_index) \
    value reference_array = *gc_root; \
    value ocaml_object = Field(reference_array, LUV_SELF_REFERENCE); \
    value callback = Field(reference_array, callback_index);

#define GET_HANDLE_CALLBACK(callback_index) \
    value *gc_root = uv_handle_get_data((uv_handle_t*)c_handle); \
    GET_REFERENCES(callback_index)

#define GET_REQUEST_CALLBACK(callback_index) \
    value *gc_root = uv_req_get_data((uv_req_t*)c_request); \
    GET_REFERENCES(callback_index)

static void luv_after_work_trampoline(uv_work_t *c_request, int status)
{
    caml_acquire_runtime_system();
    GET_REQUEST_CALLBACK(LUV_GENERIC_CALLBACK);
    caml_callback(callback, Val_int(status));
    caml_release_runtime_system();
}

static void luv_alloc_trampoline(
    uv_handle_t *c_handle, size_t suggested_size, uv_buf_t *buffer)
{
    caml_acquire_runtime_system();

    GET_HANDLE_CALLBACK(LUV_ALLOCATE_CALLBACK);

    value bigstring = caml_callback(callback, Val_int((int)suggested_size));

    buffer->base = Caml_ba_data_val(bigstring);
    buffer->len = Caml_ba_array_val(bigstring)->dim[0];

    caml_release_runtime_system();
}

static void luv_async_trampoline(uv_async_t *c_handle)
{
    caml_acquire_runtime_system();
    GET_HANDLE_CALLBACK(LUV_GENERIC_CALLBACK);
    caml_callback(callback, ocaml_object);
    caml_release_runtime_system();
}

static void luv_check_trampoline(uv_check_t *c_handle)
{
    caml_acquire_runtime_system();
    GET_HANDLE_CALLBACK(LUV_GENERIC_CALLBACK);
    caml_callback(callback, Val_unit);
    caml_release_runtime_system();
}

static void luv_close_trampoline(uv_handle_t *c_handle)
{
    caml_acquire_runtime_system();
    GET_HANDLE_CALLBACK(LUV_GENERIC_CALLBACK);
    caml_callback(callback, ocaml_object);
    caml_release_runtime_system();
}

static void luv_connect_trampoline(uv_connect_t *c_request, int status)
{
    caml_acquire_runtime_system();
    GET_REQUEST_CALLBACK(LUV_GENERIC_CALLBACK);
    caml_callback(callback, Val_int(status));
    caml_release_runtime_system();
}

static void luv_connection_trampoline(uv_stream_t *c_handle, int status)
{
    caml_acquire_runtime_system();
    GET_HANDLE_CALLBACK(LUV_CONNECTION_CALLBACK);
    caml_callback(callback, Val_int(status));
    caml_release_runtime_system();
}

static void luv_exit_trampoline(
    uv_process_t *c_handle, int64_t exit_status, int term_signal)
{
    caml_acquire_runtime_system();
    GET_HANDLE_CALLBACK(LUV_GENERIC_CALLBACK);
    caml_callback3(
        callback, ocaml_object, Val_int(exit_status), Val_int(term_signal));
    caml_release_runtime_system();
}

static void luv_fs_request_trampoline(uv_fs_t *c_request)
{
    caml_acquire_runtime_system();
    GET_REQUEST_CALLBACK(LUV_GENERIC_CALLBACK);
    caml_callback(callback, Val_unit);
    caml_release_runtime_system();
}

static void luv_idle_trampoline(uv_idle_t *c_handle)
{
    caml_acquire_runtime_system();
    GET_HANDLE_CALLBACK(LUV_GENERIC_CALLBACK);
    caml_callback(callback, Val_unit);
    caml_release_runtime_system();
}

uv_key_t luv_once_callback_key;

static void luv_once_trampoline()
{
    value callback = (value)uv_key_get(&luv_once_callback_key);
    caml_callback(callback, Val_unit);
}

static void luv_poll_trampoline(uv_poll_t *c_handle, int status, int event)
{
    caml_acquire_runtime_system();
    GET_HANDLE_CALLBACK(LUV_GENERIC_CALLBACK);
    caml_callback2(callback, Val_int(status), Val_int(event));
    caml_release_runtime_system();
}

static void luv_prepare_trampoline(uv_prepare_t *c_handle)
{
    caml_acquire_runtime_system();
    GET_HANDLE_CALLBACK(LUV_GENERIC_CALLBACK);
    caml_callback(callback, Val_unit);
    caml_release_runtime_system();
}

static void luv_read_trampoline(
    uv_stream_t *c_handle, ssize_t nread, uv_buf_t *buffer)
{
    caml_acquire_runtime_system();
    GET_HANDLE_CALLBACK(LUV_READ_CALLBACK);
    caml_callback(callback, Val_int((int)nread));
    caml_release_runtime_system();
}

static void luv_shutdown_trampoline(uv_shutdown_t *c_request, int status)
{
    caml_acquire_runtime_system();
    GET_REQUEST_CALLBACK(LUV_GENERIC_CALLBACK);
    caml_callback(callback, Val_int(status));
    caml_release_runtime_system();
}

static void luv_signal_trampoline(uv_signal_t *c_handle, int signum)
{
    caml_acquire_runtime_system();
    GET_HANDLE_CALLBACK(LUV_GENERIC_CALLBACK);
    caml_callback(callback, Val_unit);
    caml_release_runtime_system();
}

static void luv_thread_trampoline(void *argument)
{
    // The argument to this trampoline is a GC root, which points to the OCaml
    // function to call in the new thread.

    caml_c_thread_register();
    caml_acquire_runtime_system();

    value *gc_root = (value*)argument;
    value callback = *gc_root;

    caml_remove_generational_global_root(gc_root);
    caml_stat_free(gc_root);

    caml_callback(callback, Val_unit);

    caml_release_runtime_system();
    caml_c_thread_unregister();
}

static void luv_timer_trampoline(uv_timer_t *c_handle)
{
    caml_acquire_runtime_system();
    GET_HANDLE_CALLBACK(LUV_GENERIC_CALLBACK);
    caml_callback(callback, Val_unit);
    caml_release_runtime_system();
}

static void luv_work_trampoline(uv_work_t *c_request)
{
    // caml_c_thread_register and caml_c_thread_unregister can both fail, but we
    // have no good way of reporting the failure, as we have no way of
    // communicating it back to OCaml code. Perhaps the data structures need to
    // be adjusted to permit this.

    caml_c_thread_register();
    caml_acquire_runtime_system();

    GET_REQUEST_CALLBACK(LUV_WORK_FUNCTION);
    caml_callback(callback, Val_unit);

    caml_release_runtime_system();
    caml_c_thread_unregister();
}

static void luv_write_trampoline(uv_write_t *c_request, int status)
{
    caml_acquire_runtime_system();
    GET_REQUEST_CALLBACK(LUV_GENERIC_CALLBACK);
    caml_callback(callback, Val_int(status));
    caml_release_runtime_system();
}

uv_after_work_cb luv_address_of_after_work_trampoline()
{
    return luv_after_work_trampoline;
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

uv_connect_cb luv_address_of_connect_trampoline()
{
    return luv_connect_trampoline;
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

uv_fs_cb luv_address_of_fs_trampoline()
{
    return luv_fs_request_trampoline;
}

uv_fs_cb luv_null_fs_callback_pointer()
{
    return NULL;
}

uv_idle_cb luv_address_of_idle_trampoline()
{
    return luv_idle_trampoline;
}

luv_once_cb luv_address_of_once_trampoline()
{
    return luv_once_trampoline;
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

uv_shutdown_cb luv_address_of_shutdown_trampoline()
{
    return luv_shutdown_trampoline;
}

uv_signal_cb luv_address_of_signal_trampoline()
{
    return luv_signal_trampoline;
}

uv_thread_cb luv_address_of_thread_trampoline()
{
    return luv_thread_trampoline;
}

uv_timer_cb luv_address_of_timer_trampoline()
{
    return luv_timer_trampoline;
}

uv_work_cb luv_address_of_work_trampoline()
{
    return luv_work_trampoline;
}

uv_write_cb luv_address_of_write_trampoline()
{
    return luv_write_trampoline;
}



// Modifiers for uv_queue_work requests when calling a C function.
enum {
    C_OCAML_GC_ROOT,
    C_FUNCTION,
    C_ARGUMENT,
    C_FIELD_COUNT
};

int luv_add_c_function_and_argument(
    uv_work_t *c_request, intnat function, intnat argument)
{
    void **c_fields = malloc(C_FIELD_COUNT * sizeof(void*));
    if (c_fields == NULL)
        return 0;

    c_fields[C_OCAML_GC_ROOT] = uv_req_get_data((uv_req_t*)c_request);
    c_fields[C_FUNCTION] = (void*)function;
    c_fields[C_FIELD_COUNT] = (void*)argument;

    uv_req_set_data((uv_req_t*)c_request, c_fields);

    return 1;
}

static void luv_after_c_work_trampoline(uv_work_t *c_request, int status)
{
    void **c_fields = uv_req_get_data((uv_req_t*)c_request);
    uv_req_set_data((uv_req_t*)c_request, c_fields[C_OCAML_GC_ROOT]);
    free(c_fields);

    luv_after_work_trampoline(c_request, status);
}

static void luv_c_work_trampoline(uv_work_t *c_request)
{
    void **c_fields = uv_req_get_data((uv_req_t*)c_request);
    void (*function)(void*) = c_fields[C_FUNCTION];
    void *argument = c_fields[C_ARGUMENT];
    function(argument);
}

uv_after_work_cb luv_address_of_after_c_work_trampoline()
{
    return luv_after_c_work_trampoline;
}

uv_work_cb luv_address_of_c_work_trampoline()
{
    return luv_c_work_trampoline;
}

int luv_thread_create_c(uv_thread_t *tid, intnat entry, intnat arg)
{
    return uv_thread_create(tid, (void*)entry, (void*)arg);
}

int luv_once_init(uv_once_t *guard)
{
    static int tls_key_initialized = 0;

    if (tls_key_initialized == 0) {
        int result = uv_key_create(&luv_once_callback_key);
        if (result != 0)
            return result;

        tls_key_initialized = 1;
    }

    *guard = UV_ONCE_INIT;

    return 0;
}

CAMLprim value luv_set_once_callback(value callback)
{
    uv_key_set(&luv_once_callback_key, (void*)callback);
    return Val_unit;
}





// Warning-suppressing wrappers.

char* luv_strerror(int err)
{
    return (char*)uv_strerror(err);
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



// File descriptor helpers.

int luv_is_invalid_handle_value(uv_os_fd_t handle)
{
    if (handle == -1)
        return 1;
    else
        return 0;
}

int luv_is_invalid_socket_value(uv_os_sock_t socket)
{
    if (socket == -1)
        return 1;
    else
        return 0;
}

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



// Other helpers.

char* luv_version_suffix()
{
    return UV_VERSION_SUFFIX;
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

    caml_release_runtime_system();
    int result = uv_spawn(loop, handle, &options);
    caml_acquire_runtime_system();

    return result;
}