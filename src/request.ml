(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



include Helpers.Retained
  (struct
    include C.Types.Request
    type 'kind base = 'kind request
    include C.Functions.Request
  end)

let cancel request =
  C.Functions.Request.cancel (coerce request)
  |> Error.to_result ()

let set_callback request callback =
  let callback value =
    release request;
    callback value
  in
  set_reference request callback
