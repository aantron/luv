module Request_ =
struct
  type t = [ `Work ] Request.t

  let make () =
    Request.allocate
      ~reference_count:C.Types.Work.reference_count C.Types.Work.t
end

let work_trampoline =
  C.Functions.Work.get_work_trampoline ()

let after_work_trampoline =
  C.Functions.Work.get_after_work_trampoline ()

let queue_work ?loop ?(request = Request_.make ()) f callback =
  let return_value_cell = ref None in
  let f () =
    return_value_cell := Some (f ());
  in
  Request.set_reference ~index:C.Types.Work.function_index request f;
  Request.set_reference ~index:C.Types.Handle.generic_callback_index request
      begin fun result ->

    Request.release request;
    result
    |> Error.to_result_lazy (fun () ->
      match !return_value_cell with
      | Some result -> result
      | None -> assert false)
    |> callback
  end;

  let immediate_result =
    C.Functions.Work.queue
      (Loop.or_default loop) request work_trampoline after_work_trampoline
  in

  if immediate_result < Error.success then begin
    Request.release request;
    callback (Result.Error immediate_result)
  end

let c_work_trampoline =
  C.Functions.Work.get_c_work_trampoline ()

let after_c_work_trampoline =
  C.Functions.Work.get_after_c_work_trampoline ()

let queue_c_work
    ?loop
    ?(request = Request_.make ())
    ?(argument = Nativeint.zero)
    ~f
    callback =

  Request.set_reference ~index:C.Types.Handle.generic_callback_index request
      begin fun result ->

    Request.release request;
    callback result
  end;

  let result =
    C.Functions.Work.add_c_function_and_argument request f argument in
  if not result then begin
    Request.release request;
    callback Error.enomem
  end

  else begin
    let immediate_result =
      C.Functions.Work.queue
        (Loop.or_default loop) request c_work_trampoline after_c_work_trampoline
    in

    if immediate_result < Error.success then begin
      Request.release request;
      callback immediate_result
    end
  end

module Request = Request_

let set_thread_pool_size ?(if_not_already_set = false) thread_count =
  let already_set =
    try ignore (Unix.getenv "UV_THREADPOOL_SIZE"); true
    with Not_found -> false
  in
  if already_set && if_not_already_set then
    ()
  else
    Unix.putenv "UV_THREADPOOL_SIZE" (string_of_int thread_count)
