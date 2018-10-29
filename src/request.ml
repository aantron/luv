include Helpers.Retained
  (struct
    include C.Types.Request
    type 'kind base = 'kind request
    include C.Functions.Request
  end)

(* TODO Proper memory management for cancel? *)
let cancel request =
  C.Functions.Request.cancel (coerce request)

let set_callback_1 request callback =
  let callback () =
    release request;
    callback request
  in
  set_reference request callback

let set_callback_2 request callback =
  let callback v =
    release request;
    callback request v
  in
  set_reference request callback
