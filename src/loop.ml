(* TODO *)
(* include Luv_FFI.C.Types.Loop *)

include Luv_FFI.C.Functions.Loop

type t = Luv_FFI.C.Types.Loop.t Ctypes.ptr

let init () =
  let loop = Ctypes.addr (Ctypes.make Luv_FFI.C.Types.Loop.t) in
  let result = Luv_FFI.C.Functions.Loop.init loop in
  Error.to_result loop result

let configure loop option value =
  Luv_FFI.C.Functions.Loop.configure loop option (Obj.magic value)

let or_default maybe_loop =
  match maybe_loop with
  | Some loop -> loop
  | None -> Luv_FFI.C.Functions.Loop.default ()

module Run_mode = Luv_FFI.C.Types.Loop.Run_mode
module Option = Luv_FFI.C.Types.Loop.Option
