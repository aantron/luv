#include <caml/mlvalues.h>
#include <uv.h>

CAMLprim value retrieve_constant(value unit)
{
    return Val_int(UV_EBADF);
}
