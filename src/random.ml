(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Async =
struct
  let trampoline =
    C.Functions.Random.get_trampoline ()

  let random ?loop buffer callback =
    let request = Request.allocate C.Types.Random.Request.t in
    Request.set_callback request begin fun result ->
      ignore (Compatibility.Sys.opaque_identity buffer);
      Error.catch_exceptions callback (Error.to_result () result)
    end;

    let immediate_result =
      C.Functions.Random.random
        (Loop.or_default loop)
        request
        Ctypes.(bigarray_start array1 buffer)
        (Unsigned.Size_t.of_int (Buffer.size buffer))
        Unsigned.UInt.zero
        trampoline
    in

    if immediate_result < 0 then begin
      Request.release request;
      callback (Error.result_from_c immediate_result)
    end
end

include Async

module Sync =
struct
  let null_callback =
    C.Functions.Random.get_null_callback ()

  let random buffer =
    C.Functions.Random.random
      Ctypes.(from_voidp C.Types.Loop.t null)
      Ctypes.(from_voidp C.Types.Random.Request.t null)
      Ctypes.(bigarray_start array1 buffer)
      (Unsigned.Size_t.of_int (Buffer.size buffer))
      Unsigned.UInt.zero
      null_callback
    |> Error.to_result ()
end
