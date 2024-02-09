Threads
=======

Wait a minute! Why threads? Aren't event loops supposed to be *the* way to do
web-scale programming? Well... not always. Threads can still be very useful,
though you will have to make use of various synchronization primitives. For
example, one way to bind a library with a blocking API, without risking blocking
your whole program, is to run its functions in threads.

Today, there are two predominant threading APIs: Windows threads and
:man:`pthreads <7/pthreads.7>` on Unix. libuv's thread API is a cross-platform
approximation of pthreads, with similar semantics.

libuv threads don't follow the model of most of the rest of libuv — event loops
and callbacks. Instead, the libuv thread API is more of a direct wrapper over
your system's threading library. It is a low-level part of libuv, over which
some other parts of libuv are implemented, but which is also exposed for
applications to use.

This means that libuv thread functions can block, the same as functions in
pthreads.

Starting and waiting
--------------------

Start a thread using :api:`Luv.Thread.create <Thread/index.html#val-create>` and
wait for it to exit using :api:`Luv.Thread.join <Thread/index.html#val-join>`:

.. rubric:: :example:`threads.ml`
.. literalinclude:: ../example/threads.ml
    :language: ocaml
    :linenos:
    :emphasize-lines: 23,28,32,33

Note that this program does not call :api:`Luv.Loop.run
<Loop/index.html#val-run>`. This is because, again, threading is a separate,
simpler, and lower-level part of libuv.

libuv thread pool
-----------------

:api:`Luv.Thread_pool.queue_work <Thread_pool/index.html#val-queue_work>` can be
used to run functions in threads from libuv's thread pool, the same thread pool
libuv uses internally for filesystem and DNS requests:

.. rubric:: :example:`thread_pool.ml`
.. literalinclude:: ../example/thread_pool.ml
    :language: ocaml
    :linenos:
    :emphasize-lines: 2

This can be easier than creating individual threads, because it is not necessary
to keep track of each thread to later call :api:`Luv.Thread.join
<Thread/index.html#val-join>`. The thread pool requests are registered with a
libuv event loop, so a single call to :api:`Luv.Loop.run
<Loop/index.html#val-run>` is enough to wait for all of them.

Use :api:`Luv.Thread_pool.set_size <Thread_pool/index.html#val-set_size>` to
set the size of the libuv thread pool. This function should be called by
applications (not libraries) as early as possible during their initialization.

Synchronization primitives
--------------------------

libuv offers several cross-platform synchronization primitives, which work
largely like their pthreads counterparts:

- :api:`Luv.Mutex <Mutex/index.html>` — mutexes
- :api:`Luv.Rwlock <Rwlock/index.html>` — read-write locks
- :api:`Luv.Semaphore <Semaphore/index.html>` — semaphores
- :api:`Luv.Condition <Condition/index.html>` — condition variables
- :api:`Luv.Barrier <Barrier/index.html>` — barriers
- :api:`Luv.Once <Once/index.html>` — once-only barriers
- :api:`Luv.TLS <TLS/index.html>` — thread-local storage

Here's an example that uses a mutex to wait for a thread to finish its work:

.. rubric:: :example:`mutex.ml`
.. literalinclude:: ../example/mutex.ml
    :language: ocaml
    :linenos:
    :emphasize-lines: 3,5,7,10

Inter-thread communication
--------------------------

In addition to all the synchronization primitives listed above, libuv offers one
more method of inter-thread communication. If you have a thread that is blocked
inside :api:`Luv.Loop.run <Loop/index.html#val-run>`, as your program's main
thread typically would be, you can cause :api:`Luv.Loop.run
<Loop/index.html#val-run>` to "wake up" and run a callback using :api:`Luv.Async
<Async/index.html>`:

.. rubric:: :example:`progress.ml`
.. literalinclude:: ../example/progress.ml
    :language: ocaml
    :linenos:
    :emphasize-lines: 7,15,21,25

Technically, this is a form of *inter-loop* communication, since the
notification is received by a loop, in whatever thread happens to be calling
:api:`Luv.Loop.run <Loop/index.html#val-run>` for that loop. The notification
can be sent by any thread.

.. warning::

    The callback may be invoked immediately after :api:`Luv.Async.send
    <Async/index.html#val-send>` is called, or after some time. libuv may
    combine multiple calls to :api:`Luv.Async.send
    <Async/index.html#val-send>` into one callback call.

Multiple event loops
--------------------

You can run multiple libuv event loops. A complex application might have several
"primary" threads, each running its own event loop, several ordinary worker
threads, and be communicating with some external processes, some of which might
also be running libuv.

To run multiple event loops, create them with :api:`Luv.Loop.init
<Loop/index.html#val-init>`. Then, pass them as the ``?loop`` arguments to the
various Luv APIs. Here are some sample calls:

.. code-block:: ocaml

    let secondary_loop = Luv.Loop.init () |> Stdlib.Result.get_ok in (* ... *)

    ignore @@ Luv.Loop.run ~loop:secondary_loop ();

    Luv.File.open_ ~loop:secondary_loop "foo" [`RDONLY] (fun _ -> (* ... *))

In the future, Luv may lazily create a loop on demand in each thread when it
first tries to use libuv, store a reference to it in a TLS key, and pass that as
the default value of the ``?loop`` argument throughout the API.

OCaml runtime lock
------------------

Luv integrates libuv with the OCaml runtime lock. This means that, as in any
other OCaml program, two threads cannot be running OCaml code at the same time.
However, Luv releases the lock when calling a potentially-blocking libuv API, so
that other threads can run while the calling thread is blocked. In particular,
the lock is released during calls to :api:`Luv.Loop.run
<Loop/index.html#val-run>`, which means that other threads can run in between
when you make a call to a *non-blocking* API, and when its callback is called by
libuv.
