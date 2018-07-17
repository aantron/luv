#include <stdlib.h>

#define CAML_NAME_SPACE
#include <caml/bigarray.h>
#include <caml/callback.h>
#include "ctypes_cstubs_internals.h"

#include <uv.h>
#include "trampolines.h"



// TODO Camllocal? Not needed, because there is already a gc root pointing to
// the callback.
#define GET_HANDLE_CALLBACK(callback_index) \
    value *gc_root = uv_handle_get_data((uv_handle_t*)c_handle); \
    value ocaml_handle = *gc_root; \
    value callback_table = Field(ocaml_handle, 0); \
    value callback = Field(callback_table, callback_index);

// TODO Explain why not using cstubs_inverted (too much factoring of ocaml code
// required).


static void luv_nullary_handle_trampoline(uv_handle_t *c_handle)
{
    // TODO Restore.
    // caml_acquire_runtime_system();
    GET_HANDLE_CALLBACK(LUV_HANDLE_GENERIC_CALLBACK_INDEX);
    caml_callback(callback, ocaml_handle);
    // caml_release_runtime_system();
}

uv_close_cb luv_address_of_close_trampoline()
{
    return (uv_close_cb)luv_nullary_handle_trampoline;
}

uv_timer_cb luv_address_of_timer_trampoline()
{
    return (uv_timer_cb)luv_nullary_handle_trampoline;
}

uv_prepare_cb luv_address_of_prepare_trampoline()
{
    return (uv_prepare_cb)luv_nullary_handle_trampoline;
}

uv_check_cb luv_address_of_check_trampoline()
{
    return (uv_check_cb)luv_nullary_handle_trampoline;
}

uv_idle_cb luv_address_of_idle_trampoline()
{
    return (uv_idle_cb)luv_nullary_handle_trampoline;
}

uv_async_cb luv_address_of_async_trampoline()
{
    return (uv_async_cb)luv_nullary_handle_trampoline;
}


static void luv_poll_trampoline(uv_poll_t *c_handle, int status, int event)
{
    // caml_acquire_runtime_system();
    GET_HANDLE_CALLBACK(LUV_HANDLE_GENERIC_CALLBACK_INDEX);
    caml_callback3(callback, ocaml_handle, Val_int(status), Val_int(event));
    // caml_release_runtime_system();
}

uv_poll_cb luv_address_of_poll_trampoline()
{
    return luv_poll_trampoline;
}


static void luv_signal_trampoline(uv_signal_t *c_handle, int signum)
{
    // caml_acquire_runtime_system();
    GET_HANDLE_CALLBACK(LUV_HANDLE_GENERIC_CALLBACK_INDEX);
    caml_callback2(callback, ocaml_handle, Val_int(signum));
    // caml_release_runtime_system();
}

uv_signal_cb luv_address_of_signal_trampoline()
{
    return luv_signal_trampoline;
}


static void luv_connection_trampoline(uv_stream_t *c_handle, int status)
{
    GET_HANDLE_CALLBACK(LUV_CONNECTION_CALLBACK_INDEX);
    caml_callback2(callback, ocaml_handle, Val_int(status));
}

uv_connection_cb luv_address_of_connection_trampoline()
{
    return luv_connection_trampoline;
}



#define GET_REQUEST_CALLBACK() \
    value *gc_root = uv_req_get_data((uv_req_t*)c_request); \
    value ocaml_request = *gc_root; \
    value callback = Field(ocaml_request, 0);


static void luv_nullary_request_trampoline(uv_req_t *c_request, int status)
{
    GET_REQUEST_CALLBACK();
    caml_callback2(callback, ocaml_request, Val_int(status));
}

uv_connect_cb luv_address_of_connect_trampoline()
{
    return (uv_connect_cb)luv_nullary_request_trampoline;
}

uv_write_cb luv_address_of_write_trampoline()
{
    return (uv_write_cb)luv_nullary_request_trampoline;
}

uv_shutdown_cb luv_address_of_shutdown_trampoline()
{
    return (uv_shutdown_cb)luv_nullary_request_trampoline;
}



// TODO Note about alignment requirements of value.
// TODO Note assumptions about gc.
// TODO This stuff is not necessary: it is possible to allocate a managed array
// and hand over control of the C buffer.

static void luv_alloc_trampoline(
    uv_handle_t *c_handle, size_t suggested_size, uv_buf_t *buffer)
{
    GET_HANDLE_CALLBACK(LUV_ALLOCATE_CALLBACK_INDEX);

    value bigstring =
        caml_callback2(callback, ocaml_handle, Val_int((int)suggested_size));

    buffer->base = Caml_ba_data_val(bigstring);
    buffer->len = Caml_ba_array_val(bigstring)->dim[0];
}

uv_alloc_cb luv_address_of_alloc_trampoline()
{
    return luv_alloc_trampoline;
}



// caml_alloc(n, t) returns a fresh block of size n with tag t. If t is less than No_scan_tag, then the fields of the block are initialized with a valid value in order to satisfy the GC constraints.
// TODO This should really be tested for memory leaks with EOF, errors, and
// other conditions.
// TODO
// Note nread might be 0, which does not indicate an error or EOF. This is equivalent to EAGAIN or EWOULDBLOCK under read(2).
static void luv_read_trampoline(
    uv_stream_t *c_handle, ssize_t nread, const uv_buf_t *buffer)
{
    GET_HANDLE_CALLBACK(LUV_READ_CALLBACK_INDEX);
    caml_callback2(callback, ocaml_handle, Val_int((int)nread));

    /*
    CAMLparam0();
    CAMLlocal3(result, bigstring, bigstring_and_length);

    // TODO Explain why allocating the entire result here.
    if (nread > 0) {
        // Wrap the buffer in an OCaml bigstring. The C memory will be freed
        // when the GC collects the bigstring.
        intnat length = buffer->len;
        bigstring =
            caml_ba_alloc(
                CAML_BA_CHAR | CAML_BA_C_LAYOUT | CAML_BA_MANAGED, 1,
                buffer->base, &length);

        // Allocate an OCaml result reprsenting Ok (bigstring, nread).
        bigstring_and_length = caml_alloc(2, 0);
        Store_field(bigstring_and_length, 0, bigstring);
        Store_field(bigstring_and_length, 1, Val_int(nread));
        result = caml_alloc(1, 0);
        Store_field(result, 0, bigstring_and_length);
    }
    else {
        // EOF or error. In this case, if a buffer has been allocated, we need
        // to free it.
        if (buffer->base != NULL)
            free(buffer->base);

        // Allocate an OCaml result representing Error nread.
        result = caml_alloc(1, 1);
        Store_field(result, 0, Val_int(nread));
    }

    GET_HANDLE_CALLBACK(LUV_READ_CALLBACK_INDEX);

    caml_callback2(callback, ocaml_handle, result);

    CAMLreturn0;
    */
}

uv_read_cb luv_address_of_read_trampoline()
{
    return luv_read_trampoline;
}

uv_buf_t* bigstrings_to_iovecs(value bigstrings, int count)
{
    // TODO Error handling?
    uv_buf_t *iovecs = malloc(sizeof(uv_buf_t) * count);

    for (int index = 0; index < count; ++index) {
        value bigstring = Field(bigstrings, 0);
        bigstrings = Field(bigstrings, 1);

        iovecs[index] =
            uv_buf_init(
                Caml_ba_data_val(bigstring),
                Caml_ba_array_val(bigstring)->dim[0]);
    }

    return iovecs;
}
