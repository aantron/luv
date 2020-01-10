(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



open Test_helpers

module Event =
struct
  type t = {
    mutable occurred : bool;
    mutex : Mutex.t;
    condition : Condition.t;
  }

  let create () = {
    occurred = false;
    mutex = Mutex.create ();
    condition = Condition.create ();
  }

  let wait event =
    Mutex.lock event.mutex;
    while not event.occurred do
      Condition.wait event.condition event.mutex
    done;
    Mutex.unlock event.mutex

  let signal event =
    Mutex.lock event.mutex;
    event.occurred <- true;
    Condition.signal event.condition;
    Mutex.unlock event.mutex
end

let get_thread_id () =
  Thread.(id (self ()))

let tests = [
  "thread", [
    "work", `Quick, begin fun () ->
      let ran = ref false in
      let finished = ref false in

      Luv.Thread.Pool.queue_work (fun () -> ran := true) begin fun result ->
        check_success_result "queue_work" result;
        finished := true
      end;

      run ();

      Alcotest.(check bool) "ran" true !ran;
      Alcotest.(check bool) "finished" true !finished
    end;

    "work: work exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        Luv.Thread.Pool.queue_work (fun () -> raise Exit) ignore;
        run ()
      end
    end;

    "work: end exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        Luv.Thread.Pool.queue_work ignore (fun _ -> raise Exit);
        run ()
      end
    end;

    "create", `Quick, begin fun () ->
      let parent_thread_id = get_thread_id () in
      let child_thread_id = ref parent_thread_id in
      let finished = Event.create () in

      Luv.Thread.create begin fun () ->
        child_thread_id := get_thread_id ();
        Event.signal finished
      end
      |> check_success_result "create"
      |> ignore;

      Event.wait finished;

      if !child_thread_id = parent_thread_id then
        Alcotest.failf "Expected different thread ids, got %i and %i"
          !child_thread_id parent_thread_id
    end;

    "self, equal", `Quick, begin fun () ->
      let self_ = Luv.Thread.self () in
      Alcotest.(check bool) "self" true Luv.Thread.(equal (self ()) self_);

      let finished = Event.create () in

      let child_thread_id_in_child = ref self_ in
      let child_thread_id_in_parent =
        check_success_result "create" @@
        Luv.Thread.create begin fun () ->
          child_thread_id_in_child := Luv.Thread.self ();
          Event.signal finished
        end
      in

      Event.wait finished;

      Alcotest.(check bool) "child" true
        (Luv.Thread.equal child_thread_id_in_parent !child_thread_id_in_child);
      Alcotest.(check bool) "different" false
        (Luv.Thread.equal child_thread_id_in_parent self_)
    end;

    "join", `Quick, begin fun () ->
      let ran = ref false in

      let child =
        Luv.Thread.create (fun () -> ran := true)
        |> check_success_result "create"
      in

      Alcotest.(check bool) "not started" false !ran;

      Luv.Thread.join child
      |> check_success_result "join";

      Alcotest.(check bool) "ran" true !ran
    end;

    "create: exception", `Quick, begin fun () ->
      check_exception Exit begin fun () ->
        Luv.Thread.create (fun () -> raise Exit)
        |> check_success_result "create"
        |> Luv.Thread.join
        |> check_success_result "join"
      end
    end;

    (* This variant of the join test above failed when join was accidentally
       implemented in a way as to not drop the OCaml runtime lock. This is most
       likely because there is no intervening allocation by Alcotest in this
       variant. *)
    "join: pipe", `Quick, begin fun () ->
      let ran = ref false in

      Luv.Thread.create (fun () -> ran := true)
      |> check_success_result "create"
      |> Luv.Thread.join
      |> check_success_result "join";

      Alcotest.(check bool) "ran" true !ran
    end;

    "join: sequenced", `Quick, begin fun () ->
      let child = Luv.Thread.create ignore |> check_success_result "create" in
      Luv.Thread.join child
      |> check_success_result "join";
      Luv.Thread.join child
      |> check_error_result "second join" Luv.Error.esrch
    end;

    "function leak", `Quick, begin fun () ->
      no_memory_leak begin fun _ ->
        Luv.Thread.create (make_callback ())
        |> check_success_result "create"
        |> Luv.Thread.join
        |> check_success_result "join"
      end
    end;

    "tls: two threads", `Quick, begin fun () ->
      let key = Luv.TLS.create () |> check_success_result "create" in
      Luv.TLS.set key (Nativeint.of_int 42);
      Alcotest.(check int) "parent initial"
        42 (Nativeint.to_int (Luv.TLS.get key));

      let value_in_child = ref Nativeint.zero in
      Luv.Thread.create begin fun () ->
        Luv.TLS.set key (Nativeint.of_int 1337);
        value_in_child := Luv.TLS.get key
      end
      |> check_success_result "create"
      |> Luv.Thread.join
      |> check_success_result "join";
      Alcotest.(check int) "child" 1337 (Nativeint.to_int !value_in_child);

      Alcotest.(check int) "parent final"
        42 (Nativeint.to_int (Luv.TLS.get key));

      Luv.TLS.delete key
    end;

    "tls: two keys", `Quick, begin fun () ->
      let key_1 = Luv.TLS.create () |> check_success_result "create 1" in
      let key_2 = Luv.TLS.create () |> check_success_result "create 2" in

      Luv.TLS.set key_1 (Nativeint.of_int 42);
      Luv.TLS.set key_2 (Nativeint.of_int 1337);

      Alcotest.(check int) "value 1"
        42 (Nativeint.to_int (Luv.TLS.get key_1));
      Alcotest.(check int) "value 2"
        1337 (Nativeint.to_int (Luv.TLS.get key_2));

      Luv.TLS.delete key_1;
      Luv.TLS.delete key_2
    end;

    "once", `Quick, begin fun () ->
      let guard = Luv.Once.init () |> check_success_result "init" in

      let ran_1 = ref false in
      Luv.Once.once guard (fun () -> ran_1 := true);

      let ran_2 = ref false in
      Luv.Once.once guard (fun () -> ran_2 := true);

      Alcotest.(check bool) "ran 1" true !ran_1;
      Alcotest.(check bool) "ran 2" false !ran_2
    end;

    "mutex", `Quick, begin fun () ->
      let mutex = Luv.Mutex.init () |> check_success_result "init" in

      Luv.Mutex.trylock mutex |> check_success_result "trylock 1";
      Luv.Mutex.trylock mutex |> check_error_result "trylock 2" Luv.Error.ebusy;

      let child_trylock_result = ref (Result.Ok ()) in
      let child_tried_to_lock = Event.create () in
      let child =
        check_success_result "thread create" @@
        Luv.Thread.create begin fun () ->
          child_trylock_result := Luv.Mutex.trylock mutex;
          Event.signal child_tried_to_lock;
          Luv.Mutex.lock mutex
        end
      in

      Event.wait child_tried_to_lock;
      check_error_result "child trylock" Luv.Error.ebusy !child_trylock_result;

      Luv.Mutex.unlock mutex;
      Luv.Thread.join child |> check_success_result "join";

      Luv.Mutex.trylock mutex |> check_error_result "trylock 3" Luv.Error.ebusy;
      Luv.Mutex.unlock mutex;

      Luv.Mutex.destroy mutex
    end;

    "rwlock: readers", `Quick, begin fun () ->
      let rwlock = Luv.Rwlock.init () |> check_success_result "init" in

      Luv.Rwlock.tryrdlock rwlock |> check_success_result "tryrdlock";

      Luv.Thread.create begin fun () ->
        Luv.Rwlock.rdlock rwlock;
        Luv.Rwlock.rdunlock rwlock
      end
      |> check_success_result "thread create"
      |> Luv.Thread.join
      |> check_success_result "join";

      Luv.Rwlock.rdunlock rwlock;

      Luv.Rwlock.destroy rwlock
    end;

    "rwlock: writer", `Quick, begin fun () ->
      let rwlock = Luv.Rwlock.init () |> check_success_result "init" in

      Luv.Rwlock.wrlock rwlock;

      let child_tryrdlock_result = ref (Result.Ok ()) in
      let child_trywrlock_result = ref (Result.Ok ()) in
      Luv.Thread.create begin fun () ->
        child_tryrdlock_result := Luv.Rwlock.tryrdlock rwlock;
        child_trywrlock_result := Luv.Rwlock.trywrlock rwlock
      end
      |> check_success_result "thread create"
      |> Luv.Thread.join
      |> check_success_result "join";
      check_error_result "tryrdlock" Luv.Error.ebusy !child_tryrdlock_result;
      check_error_result "trywrlock" Luv.Error.ebusy !child_trywrlock_result;

      Luv.Rwlock.wrunlock rwlock;

      Luv.Rwlock.destroy rwlock
    end;

    "semaphore", `Quick, begin fun () ->
      let semaphore = Luv.Semaphore.init 2 |> check_success_result "init" in

      Luv.Semaphore.trywait semaphore |> check_success_result "trywait 1";
      Luv.Semaphore.wait semaphore;
      Luv.Semaphore.trywait semaphore
      |> check_error_result "trywait 2" Luv.Error.eagain;
      Luv.Semaphore.post semaphore;
      Luv.Semaphore.trywait semaphore |> check_success_result "trywait 3";

      Luv.Semaphore.destroy semaphore
    end;

    "condition", `Quick, begin fun () ->
      let mutex = Luv.Mutex.init () |> check_success_result "mutex init" in
      let condition = Luv.Condition.init () |> check_success_result "init" in

      Luv.Mutex.lock mutex;

      ignore @@
      Luv.Thread.create begin fun () ->
        Luv.Mutex.lock mutex;
        Luv.Condition.signal condition;
        Luv.Mutex.unlock mutex;
      end;

      Luv.Condition.wait condition mutex;

      ignore @@
      Luv.Thread.create begin fun () ->
        Luv.Mutex.lock mutex;
        Luv.Condition.broadcast condition;
        Luv.Mutex.unlock mutex;
      end;

      Luv.Condition.wait condition mutex;

      (* 100ms. *)
      Luv.Condition.timedwait condition mutex 100000000
      |> check_error_result "timedwait" Luv.Error.etimedout;

      Luv.Mutex.unlock mutex;

      Luv.Mutex.destroy mutex;
      Luv.Condition.destroy condition
    end;

    "barrier", `Quick, begin fun () ->
      let barrier = Luv.Barrier.init 2 |> check_success_result "init" in
      let cleanup_count = ref 0 in
      let count_cleanup yes = if yes then cleanup_count := !cleanup_count + 1 in

      let child_ran = ref false in
      let child =
        check_success_result "thread create" @@
        Luv.Thread.create begin fun () ->
          child_ran := true;
          Luv.Barrier.wait barrier |> count_cleanup
        end
      in

      Luv.Barrier.wait barrier |> count_cleanup;
      Alcotest.(check bool) "child ran" true !child_ran;

      Luv.Thread.join child
      |> check_success_result "join";

      Alcotest.(check int) "cleanup count" 1 !cleanup_count;

      Luv.Barrier.destroy barrier
    end;
  ]
]

(* TODO Test cancelation here. *)
