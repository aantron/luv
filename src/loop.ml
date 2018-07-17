include Luv_FFI.C.Types.Loop
include Luv_FFI.C.Functions.Loop

let allocate () =
  Ctypes.addr (Ctypes.make t)

let configure loop option value =
  configure loop option (Obj.magic value)

let or_default maybe_loop =
  match maybe_loop with
  | Some loop -> loop
  | None -> default ()
