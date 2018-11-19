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

(* run must always release the runtime lock, even if called with
   Run_mode.nowait. This is because calling run can trigger callbacks, and
   callbacks expect to be able to take the lock (eventually). If the lock is
   *not* released by run and a callback is called, there will be a deadlock. *)
let run ?loop ?(mode = Run_mode.default) () =
  let loop = or_default loop in
  C.Blocking.Loop.run loop mode
