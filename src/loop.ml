include C.Functions.Loop

type t = C.Types.Loop.t Ctypes.ptr

let init () =
  let loop = Ctypes.addr (Ctypes.make C.Types.Loop.t) in
  let result = C.Functions.Loop.init loop in
  Error.to_result loop result

let configure loop option value =
  C.Functions.Loop.configure loop option (Obj.magic value)

let or_default maybe_loop =
  match maybe_loop with
  | Some loop -> loop
  | None -> C.Functions.Loop.default ()

module Run_mode =
struct
  include C.Types.Loop.Run_mode
  type t = int
end

module Option =
struct
  include C.Types.Loop.Option
  type 'value t = int
end
