(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let getenv variable =
  let length = 1024 in
  let buffer = Bytes.create length in
  C.Functions.Env.getenv
    (Ctypes.ocaml_string_start variable)
    (Ctypes.ocaml_bytes_start buffer)
    (Ctypes.(allocate size_t) (Unsigned.Size_t.of_int length))
  |> Error.to_result_lazy begin fun () ->
    let length = Bytes.index buffer '\000' in
    Bytes.sub_string buffer 0 length
  end

let setenv variable ~value =
  C.Functions.Env.setenv
    (Ctypes.ocaml_string_start variable) (Ctypes.ocaml_string_start value)
  |> Error.to_result ()

let unsetenv variable =
  C.Functions.Env.unsetenv (Ctypes.ocaml_string_start variable)
  |> Error.to_result ()

let environ () =
  let env_items = Ctypes.(allocate_n (ptr C.Types.Env_item.t) ~count:1) in
  let count = Ctypes.(allocate_n int ~count:1) in
  C.Functions.Env.environ env_items count
  |> Error.to_result_lazy begin fun () ->
    let env_items = Ctypes.(!@) env_items in
    let count = Ctypes.(!@) count in
    let converted_env_items =
      Ctypes.(CArray.fold_left (fun env_items c_env_item ->
        let name = getf c_env_item C.Types.Env_item.name in
        let value = getf c_env_item C.Types.Env_item.value in
        (name, value)::env_items) [] (CArray.from_ptr env_items count))
      |> List.rev
    in
    C.Functions.Env.free_environ env_items count;
    converted_env_items
  end
