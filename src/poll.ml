type t = [ `Poll ] Handle.t

type event = [
  | `Readable
  | `Writable
  | `Disconnect
  | `Prioritized
]

let all_events = [
  `Readable;
  `Writable;
  `Disconnect;
  `Prioritized;
]

let event_to_bit = C.Types.Poll.Event.(function
  | `Readable -> readable
  | `Writable -> writable
  | `Disconnect -> disconnect
  | `Prioritized -> prioritized)

let event_list_to_bit_mask events =
  List.fold_left (fun mask event -> mask lor (event_to_bit event)) 0 events

let event_bit_mask_to_list mask =
  List.filter (fun event -> mask land (event_to_bit event) <> 0) all_events

let init ?loop ~fd () =
  let poll = Handle.allocate C.Types.Poll.t in
  C.Functions.Poll.init (Loop.or_default loop) (Handle.c poll) fd
  |> Error.to_result poll

let trampoline =
  C.Functions.Poll.get_trampoline ()

let start ~callback poll events =
  let callback poll status event_mask =
    callback poll status (event_bit_mask_to_list event_mask)
  in
  Handle.set_callback poll callback;
  C.Functions.Poll.start
    (Handle.c poll) (event_list_to_bit_mask events) trampoline

let stop poll =
  C.Functions.Poll.stop (Handle.c poll)
