(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = [ `Poll ] Handle.t

module Event =
struct
  include C.Types.Poll.Event
  type t = int
  let (lor) = (lor)
  let list events = List.fold_left (lor) 0 events
  let test events mask = (events land mask) <> 0
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
    Error.catch_exceptions callback (Error.to_result events status));
  let immediate_result = C.Functions.Poll.start poll events trampoline in
  if immediate_result < Error.success then begin
    callback (Result.Error immediate_result)
  end

let stop poll =
  C.Functions.Poll.stop poll
  |> Error.to_result ()
