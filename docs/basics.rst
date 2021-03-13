Basics
======

libuv offers an **asynchronous**, **event-driven** style of programming.  Its
core job is to provide an event loop and callback-based notifications of I/O
and other activities.  libuv offers core utilities like timers, non-blocking
networking support, asynchronous file system access, child processes, and more.

Event loops
-----------

In event-driven programming, an application expresses interest in certain events
and responds to them when they occur. The responsibility of gathering events
from the operating system or monitoring other sources of events is handled by
libuv, and the user can register callbacks to be invoked when an event occurs.
The event loop usually keeps running *forever*. In pseudocode:

.. code-block:: ocaml

    while there are still live objects that could generate events do
        let e = get the next event in
        if there is a callback waiting on e then
            call the callback
    done

Some examples of events are:

- A file is ready for writing
- A socket has data ready to be read
- A timer has timed out

This event loop is inside :api:`Luv.Loop.run <Loop/index.html#val-run>`, which
binds to ``uv_run``, the main function of libuv.

The most common activity of systems programs is to deal with input and output,
rather than a lot of number-crunching. The problem with using conventional
input/output functions (``read``, ``fprintf``, etc.) is that they are
**blocking**. The actual write to a hard disk, or reading from a network, takes
a disproportionately long time compared to the speed of the processor. The
functions don't return until the task is done, so that your program is blocked
doing nothing until then. For programs which require high performance this is a
major obstacle, as other activities and other I/O operations are kept waiting.

One of the standard solutions is to use threads. Each blocking I/O operation is
started in a separate thread, or in a thread pool. When the blocking function
gets invoked in the thread, the processor can schedule another thread to run,
which actually needs the CPU.

The approach followed by libuv uses another style, which is the **asynchronous,
non-blocking** style. Most modern operating systems provide event notification
subsystems. For example, a normal ``read`` call on a socket would block until
the sender actually sent something. Instead, the application can request the
operating system to watch the socket and put an event notification into a queue.
The application can inspect the events at its convenience and grab the data,
perhaps doing some number crunching in the meantime to use the processor to the
maximum. It is **asynchronous** because the application expressed interest at
one point, then used the data at another point in its execution sequence. It is
**non-blocking** because the application process was free to do other tasks. in
between. This fits in well with libuv's event-loop approach, since the operating
system's events can be treated as libuv events. The non-blocking ensures that
other events can continue to be handled as fast as they come in (and the
hardware allows).

Hello, world!
-------------

With the basics out of the way, let's write our first libuv program. It does
nothing, except start a loop which will exit immediately.

.. rubric:: :example:`hello_world.ml`
.. literalinclude:: ../example/hello_world.ml
    :language: ocaml
    :linenos:

This program exits immediately because it has no events to process. A libuv
event loop has to be told to watch out for events using the various libuv API
functions.

Here's a slightly more interesting program, which waits for one second, prints
“Hello, world!” and then exits:

.. rubric:: :example:`delay.ml`
.. literalinclude:: ../example/delay.ml
    :language: ocaml
    :linenos:

Console output
--------------

The first two examples used OCaml's own ``print_endline`` for console output. In
a fully asynchronous program, you may want to use libuv to write to the console
(or STDOUT) instead. Luv offers at least three ways of doing this.

Using the pre-opened file :api:`Luv.File.stdout <File/index.html#val-stdout>`:

.. rubric:: :example:`print_using_file.ml`
.. literalinclude:: ../example/print_using_file.ml
    :language: ocaml
    :linenos:

Wrapping :api:`Luv.File.stdout <File/index.html#val-stdout>` in a pipe with
:api:`Luv.Pipe.open_ <Pipe/index.html#val-open_>`:

.. rubric:: :example:`print_using_pipe.ml`
.. literalinclude:: ../example/print_using_pipe.ml
    :language: ocaml
    :linenos:

Wrapping :api:`Luv.File.stdout <File/index.html#val-stdout>` in a TTY handle
with :api:`Luv.TTY.init <TTY/index.html#val-init>`:

.. rubric:: :example:`print_using_tty.ml`
.. literalinclude:: ../example/print_using_tty.ml
    :language: ocaml
    :linenos:

As you can see, all of these are too low-level and verbose for ordinary use.
They would need to be wrapped in a higher-level library. The examples will
continue to use ``print_endline``, which is fine for most purposes.

.. _libuv-error-handling:

Error handling
--------------

When functions fail, they produce one of the error codes in :api:`Luv.Error.t
<Error/index.html#type-t>`, wrapped in the ``Error`` side of a ``result``. In
the last example above, we used :api:`Luv.Timer.init
<Timer/index.html#val-init>`, which has signature

.. code-block:: ocaml

    Luv.Timer.init : unit -> (Luv.Timer.t, Luv.Error.t) result

If a call to ``Luv.Timer.init`` succeeds, it will produce ``Ok timer``. If it
fails, it might produce ``Error `ENOMEM``.

Asynchronous operations that can fail pass the ``result`` to their callback,
instead of returning it:

.. code-block:: ocaml

    Luv.File.unlink : string -> ((unit, Luv.Error.t) result -> unit) -> unit

You can get the error name and description as strings by calling
:api:`Luv.Error.err_name <Error/index.html#val-err_name>` and
:api:`Luv.Error.strerror <Error/index.html#val-strerror>`, respectively.

libuv has several different conventions for returning errors. Luv translates all
of them into the above scheme: synchronous operations return a ``result``, and
asynchronous operations pass a ``result`` to their callback.

There is only a handful of exceptions to this, but they are all easy to
understand. For example, :api:`Luv.Timer.start <Timer/index.html#val-start>` can
fail immediately, but if it starts, it can only call its callback with success.
So, it has signature

.. code-block:: ocaml

    Luv.Timer.start :
      Luv.Timer.t -> int -> (unit -> unit) -> (unit, Luv.Error.t) result

Luv does not raise exceptions. In addition, callbacks you pass to Luv APIs
shouldn't raise exceptions at the top level (they can use exceptions interally).
This is because such exceptions can't be allowed to go up the stack into libuv.
If a callback passed to Luv raises an exception, Luv catches it, prints a stack
trace to ``STDERR``, and then calls ``exit 2``. You can change this behavior by
installing your own handler:

.. code-block:: ocaml

    Luv.Error.set_on_unhandled_exception (fun exn -> (* ... *))

Generally, only applications, rather than libraries, should call this function.

Handles
-------

libuv works by the user expressing interest in particular events. This is
usually done by creating a **handle** to an I/O device, timer or process, and
then calling a function on that handle.

The following handle types are available:

- :api:`Luv.Timer <Timer/index.html>` — timers
- :api:`Luv.Signal <Signal/index.html>` — signals
- :api:`Luv.Process <Process/index.html>` — subprocesses
- :api:`Luv.TCP <TCP/index.html>` — TCP sockets
- :api:`Luv.UDP <UDP/index.html>` — UDP sockets
- :api:`Luv.Pipe <Pipe/index.html>` — pipes
- :api:`Luv.TTY <TTY/index.html>` — consoles
- :api:`Luv.FS_event <FS_event/index.html>` — filesystem events
- :api:`Luv.FS_poll <FS_poll/index.html>` — filesystem polling
- :api:`Luv.Poll <Poll/index.html>` — file descriptor polling
- :api:`Luv.Async <Async/index.html>` — inter-loop communication
- :api:`Luv.Prepare <Prepare/index.html>` — pre-I/O callbacks
- :api:`Luv.Check <Check/index.html>` — post-I/O callbacks
- :api:`Luv.Idle <Idle/index.html>` — per-iteration callbacks

In addition to the above true handles, there is also :api:`Luv.File
<File/index.html>`, which has a similar basic interface, yet is not a
proper libuv handle kind.

Example
-------

The remaining chapters of this guide will exercise many of the modules mentioned
above, but let's work with a simple one now — that is, in addition to the timer
"Hello, world!" example we've already seen!

Here is an example of using a :api:`Luv.Idle.t <Idle/index.html#type-t>` handle.
It adds a callback, that is to be called once on every iteration of the event
loop:

.. rubric:: :example:`idle.ml`
.. literalinclude:: ../example/idle.ml
    :language: ocaml
    :linenos:

The error handling in this example is not robust! It is using ``Result.get_ok``
and ``ignore`` to avoid dealing with potential ``Error``. If you are writing a
robust application, or a library, please use a better error-handling mechanism
instead.

Requests
--------

libuv also has **requests**. Whereas handles are long-lived, a request is a
short-lived representation of one particular instance of an asynchronous
operation. Requests are used by libuv, for example, to return complex results.
Luv manages requests automatically, so the user generally does not have to deal
with them at all.

A few request types are still exposed, however, because they are cancelable, and
can be passed, at the user's discretion, to :api:`Luv.Request.cancel
<Request/index.html#val-cancel>`. Explicit use of these requests is still
optional, however — they are always taken through optional arguments. So, when
using Luv, it is possible to ignore the existence of requests entirely.

See :api:`Luv.File.Request <File/Request/index.html>` for a typical request
type, with example usage. This represents filesystem requests, which are
cancelable. Functions in :api:`Luv.File <File/index.html>` have signatures like

.. code-block:: ocaml

    Luv.File.unlink :
      ?request:Luv.File.Request.t ->
      string ->
      ((unit, Luv.Error.t) result -> unit) ->
        unit

...in case the user needs the ability to cancel the request. This guide will
generally omit the ``?request`` argument, because it is rarely used, and always
has only this one purpose.

Here are all the exposed request types in Luv:

- :api:`Luv.File.Request <File/Request/index.html>`
- :api:`Luv.DNS.Addr_info.Request <DNS/Addr_info/Request/index.html>`
- :api:`Luv.DNS.Name_info.Request <DNS/Name_info/Request/index.html>`
- :api:`Luv.Random.Request <Random/Request/index.html>`
- :api:`Luv.Thread_pool.Request <Thread_pool/Request/index.html>`

Everything else
---------------

libuv, and Luv, also offer a large number of other operations, all implemented
in a cross-platform fashion. See the full module listing in the
:api:`API index <index.html#api-reference>`. For example, one can list all
environment variables using

.. code-block:: ocaml

    Luv.Env.environ : unit -> ((string * string) list, Luv.Error.t) result

Buffers
-------

Luv functions use data buffers of type :api:`Luv.Buffer.t
<Buffer/index.html#type-t>`. These are ordinary OCaml bigstrings (that is,
chunks of data managed from OCaml, but stored in the C heap). They are
compatible with at least the following bigstring libraries:

- Bigarray_ from OCaml's standard library
- Lwt_bytes_ from Lwt
- bigstringaf_
- ocaml-bigstring_

.. _Bigarray: https://caml.inria.fr/pub/docs/manual-ocaml/libref/Bigarray.Array1.html
.. _Lwt_bytes: https://ocsigen.org/lwt/dev/api/Lwt_bytes
.. _bigstringaf: https://github.com/inhabitedtype/bigstringaf
.. _ocaml-bigstring: https://github.com/c-cube/ocaml-bigstring

System calls are usually able to work with part of a buffer, by taking a pointer
to the buffer, an offset into the buffer, and a length of space, starting at the
offset, to work with. Luv functions instead take only a buffer. To work with
part of an existing buffer, use :api:`Luv.Buffer.sub
<Buffer/index.html#val-sub>` to create a view into the buffer, and then pass the
view to Luv.

Many libuv (and Luv) functions work with *lists* of buffers. For example,
:api:`Luv.File.write <File/index.html#val-write>` takes such a list. This simply
means that libuv will pull data from the buffers consecutively for writing.
Likewise, :api:`Luv.File.read <File/index.html#val-read>` takes a list of
buffers, which it will consecutively fill. This is known as *scatter-gather
I/O*. It could be said that libuv (and Luv) expose an API more similar to
readv_ and writev_ than read_ and write_.

.. _readv: http://man7.org/linux/man-pages/man3/readv.3p.html
.. _writev: http://man7.org/linux/man-pages/man3/writev.3p.html
.. _read: http://man7.org/linux/man-pages/man3/read.3p.html
.. _write: http://man7.org/linux/man-pages/man3/write.3p.html

Luv has a couple helpers for manipulating lists of buffers:

- :api:`Luv.Buffer.total_size <Buffer/index.html#val-total_size>` returns the
  total number of bytes across all the buffers in a buffer list.
- :api:`Luv.Buffer.drop <Buffer/index.html#val-drop>` returns a new buffer list,
  with the first N bytes removed from its front. This is useful to advance the
  buffer references after a partial read into, or write from, a buffer list,
  before beginning the next read or write.

Integer types
-------------

Luv usually represents C integer types with ordinary OCaml integers, such as
``int``, sometimes ``int64``. However, in some APIs, to avoid losing precision,
it seems important to preserve the full width and signedness of the original C
type. In such cases, you will encounter types from ocaml-integers_, such as
``Unsigned.Size_t.t``. You can use module ``Unsigned.Size_t`` to perform
operations at that type, or you can choose to convert to an OCaml integer with
``Unsigned.Size_t.to_int``.

.. _ocaml-integers: https://github.com/ocamllabs/ocaml-integers
