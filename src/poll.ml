(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `Poll ] Handle.t

module Event =
struct
  type t = [
    | `READABLE
    | `WRITABLE
    | `DISCONNECT
    | `PRIORITIZED
  ]

  let to_c = let open C.Types.Poll.Event in function
    | `READABLE -> readable
    | `WRITABLE -> writable
    | `DISCONNECT -> disconnect
    | `PRIORITIZED -> prioritized

  let all = [
    `READABLE;
    `WRITABLE;
    `DISCONNECT;
    `PRIORITIZED;
  ]
end

let init ?loop fd =
  let poll = Handle.allocate C.Types.Poll.t in
  C.Functions.Poll.init (Loop.or_default loop) poll fd
  |> Error.to_result poll

let init_socket ?loop socket =
  let poll = Handle.allocate C.Types.Poll.t in
  C.Functions.Poll.init_socket (Loop.or_default loop) poll socket
  |> Error.to_result poll

let trampoline =
  C.Functions.Poll.get_trampoline ()

let start poll events callback =
  Handle.set_reference poll (fun status events ->
    let events = Helpers.Bit_flag.c_to_list Event.to_c Event.all events in
    Error.catch_exceptions callback (Error.to_result events status));
  let events = Helpers.Bit_flag.list_to_c Event.to_c events in
  let immediate_result = C.Functions.Poll.start poll events trampoline in
  if immediate_result < Error.success then begin
    callback (Result.Error immediate_result)
  end

let stop poll =
  C.Functions.Poll.stop poll
  |> Error.to_result ()
