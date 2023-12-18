#include <uv.h>
#include <caml/mlvalues.h>

CAMLprim value retrieve_constant(value unit)
{
    return Val_int(UV_EBADF);
}
