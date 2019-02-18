(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = C.Types.DLL.t Ctypes.ptr

let open_ filename =
  let lib = Ctypes.(addr (make C.Types.DLL.t)) in
  let result = C.Functions.DLL.open_ (Ctypes.ocaml_string_start filename) lib in
  if result then
    None
  else
    Some lib

let close =
  C.Functions.DLL.close

let sym lib name =
  let address = Ctypes.(allocate (ptr void) null) in
  let result =
    C.Functions.DLL.sym lib (Ctypes.ocaml_string_start name) address in
  if result then
    None
  else
    Some (Ctypes.(raw_address_of_ptr (!@ address)))

let last_error =
  C.Functions.DLL.error
