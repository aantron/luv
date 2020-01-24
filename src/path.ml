(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let exepath () =
  let length = 4096 in
  let buffer = Bytes.create length in
  C.Functions.Path.exepath
    (Ctypes.ocaml_bytes_start buffer)
    (Ctypes.(allocate size_t) (Unsigned.Size_t.of_int length))
  |> Error.to_result_lazy begin fun () ->
    let length = Bytes.index buffer '\000' in
    Bytes.sub_string buffer 0 length
  end

let cwd () =
  let length = 4096 in
  let buffer = Bytes.create length in
  C.Functions.Path.cwd
    (Ctypes.ocaml_bytes_start buffer)
    (Ctypes.(allocate size_t) (Unsigned.Size_t.of_int length))
  |> Error.to_result_lazy begin fun () ->
    let length = Bytes.index buffer '\000' in
    Bytes.sub_string buffer 0 length
  end

let chdir path =
  C.Functions.Path.chdir (Ctypes.ocaml_string_start path)
  |> Error.to_result ()

let homedir () =
  let length = 1024 in
  let buffer = Bytes.create length in
  C.Functions.Path.homedir
    (Ctypes.ocaml_bytes_start buffer)
    (Ctypes.(allocate size_t) (Unsigned.Size_t.of_int length))
  |> Error.to_result_lazy begin fun () ->
    let length = Bytes.index buffer '\000' in
    Bytes.sub_string buffer 0 length
  end

let tmpdir () =
  let length = 1024 in
  let buffer = Bytes.create length in
  C.Functions.Path.tmpdir
    (Ctypes.ocaml_bytes_start buffer)
    (Ctypes.(allocate size_t) (Unsigned.Size_t.of_int length))
  |> Error.to_result_lazy begin fun () ->
    let length = Bytes.index buffer '\000' in
    Bytes.sub_string buffer 0 length
  end
