open Test_helpers

let get_thread_id () =
  Thread.(id (self ()))

let tests = [
  "thread", [
    "work", `Quick, begin fun () ->
      let finished = ref false in

      Luv.Thread.queue_work get_thread_id begin fun result ->
        let worker_thread_id = check_success_result "queue_work" result in
        let main_thread_id = get_thread_id () in
        if worker_thread_id = main_thread_id then
          Alcotest.failf "Expected different thread ids, got %i %i"
            worker_thread_id main_thread_id;
        finished := true
      end;

      run ();

      Alcotest.(check bool) "finished" true !finished
    end;
  ]
]

(* TODO Test cancelation here. *)
