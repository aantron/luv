type 'kind t = 'kind C.Types.Request.t Ctypes.ptr

let coerce : type any_type_of_request. any_type_of_request t -> [ `Base ] t =
  Obj.magic

(* TODO Proper memory management for cancel? *)
let cancel request =
  C.Functions.Request.cancel (coerce request)

let allocate t =
  Ctypes.addr (Ctypes.make t)

(* TODO Still needed? *)
let c request =
  request

let set_callback request callback =
  let gc_root = Ctypes.Root.create callback in
  C.Functions.Request.set_data (coerce request) gc_root

let clear_callback request =
  C.Functions.Request.get_data (coerce request)
  |> Ctypes.Root.release

let set_callback_1 request callback =
  let callback () =
    clear_callback request;
    callback request
  in
  set_callback request callback

let set_callback_2 request callback =
  let callback v =
    clear_callback request;
    callback request v
  in
  set_callback request callback
