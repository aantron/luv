(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Request_ =
struct
  type t = [ `Thread_pool ] Request.t

  let make () =
    Request.allocate
      ~reference_count:C.Types.Work.reference_count C.Types.Work.t
end

let work_trampoline =
  C.Functions.Work.get_work_trampoline ()

let after_work_trampoline =
  C.Functions.Work.get_after_work_trampoline ()

let queue_work ?loop ?(request = Request_.make ()) f callback =
  let f = Error.catch_exceptions f in
  let wrapped_callback result =
    Error.catch_exceptions callback (Error.to_result () result)
  in
  Request.set_reference ~index:C.Types.Work.function_index request f;
  Request.set_callback request wrapped_callback;

  let immediate_result =
    C.Functions.Work.queue
      (Loop.or_default loop) request work_trampoline after_work_trampoline
  in

  if immediate_result < 0 then begin
    Request.release request;
    callback (Error.result_from_c immediate_result)
  end

let c_work_trampoline =
  C.Functions.Work.get_c_work_trampoline ()

let after_c_work_trampoline =
  C.Functions.Work.get_after_c_work_trampoline ()

let queue_c_work
    ?loop
    ?(request = Request_.make ())
    ?(argument = Nativeint.zero)
    f
    callback =

  let wrapped_callback result =
    Error.catch_exceptions callback (Error.to_result () result)
  in
  Request.set_callback request wrapped_callback;

  let result =
    C.Functions.Work.add_c_function_and_argument request f argument in
  if not result then begin
    Request.release request;
    callback (Error `ENOMEM)
  end

  else begin
    let immediate_result =
      C.Functions.Work.queue
        (Loop.or_default loop)
        request
        c_work_trampoline
        after_c_work_trampoline
    in

    if immediate_result < 0 then begin
      Request.release request;
      callback (Error.result_from_c immediate_result)
    end
  end

module Request = Request_

let set_size ?(if_not_already_set = false) thread_count =
  let already_set =
    match Env.getenv "UV_THREADPOOL_SIZE" with
    | Ok _ -> true
    | Error _ -> false
  in
  if already_set && if_not_already_set then
    ()
  else
    ignore (Env.setenv "UV_THREADPOOL_SIZE" ~value:(string_of_int thread_count))
