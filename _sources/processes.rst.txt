Processes
=========

libuv offers cross-platform process management, which is exposed in
:api:`Luv.Process <Process/index.html>`.

Spawning child processes
------------------------

To spawn a process, use :api:`Luv.Process.spawn <Process/index.html#val-spawn>`:

.. rubric:: :example:`spawn.ml`
.. literalinclude:: ../example/spawn.ml
    :language: ocaml
    :linenos:

The reason this mysteriously short program waits for the child ``sleep`` process
to exit is that :api:`Luv.Process.spawn <Process/index.html#val-spawn>` creates
a :api:`Luv.Process.t <Process/index.html>` handle and registers it with the
event loop, which we then run with :api:`Luv.Loop.run
<Loop/index.html#val-run>`. It is :api:`Luv.Loop.run <Loop/index.html#val-run>`
that waits. The process handle is also returned to us, but, in this example, we
call ``ignore`` on it on line 2.

:api:`Luv.Process.spawn <Process/index.html#val-spawn>` has a large number of
optional arguments for controlling the child process' working directory,
environment variables, and so on. Three of the optional arguments deserve some
extra attention:

- ``?on_exit``, if supplied, is called when the process terminates.
- ``?detached:true`` makes the child process fully independent of the parent; in
  particular, the parent can exit without killing the child.
- ``?redirect`` is the subject of the next section.

Child process I/O
-----------------

By default, the standard file descriptors of a child process all point to
``/dev/null``, or ``NUL`` on Windows. You can use the ``?redirect`` argument of
:api:`Luv.Process.spawn <Process/index.html#val-spawn>` to change this.

For example, to share the parent's ``STDOUT`` with the child:

.. rubric:: :example:`stdout.ml`
.. literalinclude:: ../example/stdout.ml
    :language: ocaml
    :linenos:

A variant of :api:`Luv.Process.inherit_fd <Process/index.html#val-inherit_fd>`
is :api:`Luv.Process.inherit_stream <Process/index.html#val-inherit_stream>`. It
does the same thing, but the function, rather than taking a raw file descriptor,
extracts a file descriptor from a libuv stream you already have in the parent
(for example, a TCP socket or a pipe).

The alternative to this is to connect a file descriptor in the child to a pipe
in the parent. The difference between having a child *inherit* a pipe, and
creating a pipe *between* parent and child, is, of course, that...

- When inheriting a pipe, the read end in the child is the same as the read end
  in the parent, and likewise for the write end, and the communication is
  typically with some third party.
- When creating a pipe for parent-child communication, the read end in the
  child is connected to the *write* end in the parent, and vice versa.

For this, you need to first create a :api:`Luv.Pipe.t <Pipe/index.html#type-t>`,
which is a kind of libuv stream. So, reading from and writing to it are done the
same way as for :ref:`TCP sockets <TCP>`.

.. rubric:: :example:`pipe.ml`
.. literalinclude:: ../example/pipe.ml
    :language: ocaml
    :linenos:
    :emphasize-lines: 5,8,10,17

IPC
---

:api:`Luv.Pipe <Pipe/index.html>` can also be used for general IPC between any
two processes. For this, a *server* pipe has to be assigned a name using
:api:`Luv.Pipe.bind <Pipe/index.html#val-bind>`, and the client connects with
:api:`Luv.Pipe.connect <Pipe/index.html#val-connect>`. After that, the flow is
largely the same as for :ref:`TCP sockets <TCP>`. Indeed, if you compare the
examples below to the ones at section :ref:`TCP`, you will see that only the
first few lines of initialization are different. Almost everything else is the
same, because both pipes and TCP sockets are libuv streams.

.. rubric:: :example:`pipe_echo_server.ml`
.. literalinclude:: ../example/pipe_echo_server.ml
    :language: ocaml
    :linenos:
    :emphasize-lines: 3,5,11,16,23

.. rubric:: :example:`pipe_hello_world.ml`
.. literalinclude:: ../example/pipe_hello_world.ml
    :language: ocaml
    :linenos:
    :emphasize-lines: 4,9,10,12

You can run the IPC server and client together with:

.. code-block::

    dune exec example/pipe_echo_server.exe &
    dune exec example/pipe_hello_world.exe
    killall pipe_echo_server.exe

Signals
-------

Despite its frightening name, :api:`Luv.Process.kill
<Process/index.html#val-kill>` only sends a signal to a given process:

.. rubric:: :example:`send_signal.ml`
.. literalinclude:: ../example/send_signal.ml
    :language: ocaml
    :linenos:
    :emphasize-lines: 5

Use :api:`Luv.Signal <Signal/index.html>` to receive signals:

.. rubric:: :example:`sigint.ml`
.. literalinclude:: ../example/sigint.ml
    :language: ocaml
    :linenos:
    :emphasize-lines: 4
