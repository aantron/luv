(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let idle_time =
   C.Functions.Metrics.idle_time

type t = {
  loop_count : Unsigned.uint64;
  events : Unsigned.uint64;
  events_waiting : Unsigned.uint64;
}

let info loop =
   let module M = C.Types.Metrics in
   let c_metrics = Ctypes.make M.t in
   C.Functions.Metrics.info loop (Ctypes.addr c_metrics)
   |> Error.to_result_f @@ fun () ->
   {
     loop_count = Ctypes.getf c_metrics M.loop_count;
     events = Ctypes.getf c_metrics M.events;
     events_waiting = Ctypes.getf c_metrics M.events_waiting;
   }
