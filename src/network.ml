(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let generic_toname c_function index =
  let length = C.Types.Network.if_namesize in
  let buffer = Bytes.create length in
  c_function
    (Unsigned.UInt.of_int index)
    (Ctypes.ocaml_bytes_start buffer)
    (Ctypes.(allocate size_t) (Unsigned.Size_t.of_int length))
  |> Error.to_result_lazy begin fun () ->
    let length = Bytes.index buffer '\000' in
    Bytes.sub_string buffer 0 length
  end

let if_indextoname = generic_toname C.Functions.Network.if_indextoname
let if_indextoiid = generic_toname C.Functions.Network.if_indextoiid

(* TODO There is some common code to factor out here. *)
let gethostname () =
  let length = C.Types.Network.maxhostnamesize in
  let buffer = Bytes.create length in
  C.Functions.Network.gethostname
    (Ctypes.ocaml_bytes_start buffer)
    (Ctypes.(allocate size_t) (Unsigned.Size_t.of_int length))
  |> Error.to_result_lazy begin fun () ->
    let length = Bytes.index buffer '\000' in
    Bytes.sub_string buffer 0 length
  end
