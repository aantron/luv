include Helpers.Retained
  (struct
    include C.Types.Request
    type 'kind base = 'kind request
    include C.Functions.Request
  end)

(* TODO Proper memory management for cancel? *)
let cancel request =
  C.Functions.Request.cancel (coerce request)

let set_callback request callback =
  let callback value =
    release request;
    callback value
  in
  set_reference request callback
