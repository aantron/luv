Filesystem
==========

.. note::

    The libuv filesystem operations are different from :doc:`socket operations
    <networking>`. Socket operations use the non-blocking operations provided
    by the operating system. Filesystem operations use blocking functions
    internally, but invoke these functions in a `thread pool`_ and notify
    watchers registered with the event loop when they complete.

.. _thread pool: http://docs.libuv.org/en/v1.x/threadpool.html#thread-pool-work-scheduling

All filesystem operations have two forms — *synchronous* and *asynchronous*.

Synchronous operations are slightly easier to program with, and are faster,
because they run in the current thread instead of the thread pool (note again:
this is only an issue for filesystem operations, not sockets or pipes). However,
they can block the thread. This can happen, for example, if you use a
synchronous operation to access a network filesystem which is slow or
unavailable. It can also happen locally. So, synchronous operations should not
be used in robust applications or libraries. Synchronous filesystem operations
are found in module :api:`Luv.File.Sync <File/Sync/index.html>`.

Asynchronous versions of all the same operations are found in the main module
:api:`Luv.File <File/index.html>`. These each take a callback, to which they
pass their result, instead of returning their result directly, as synchronous
operations do.

As already mentioned, asynchronous filesystem operations are slower than
synchronous, because running an asynchronous operation requires communicating
twice with a thread in the libuv thread pool: once to start the operation, and
once more when it is complete. In some cases, you can mitigate this cost by
manually running multiple operations in one request in the thread pool. To do
that, use :api:`Luv.Thread_pool.queue_work
<Thread_pool/index.html#val-queue_work>`, and run multiple *synchronous*
operations in the function you pass to it.

Note that this only offers a performance benefit if you run multiple operations.
Running only one operation is equivalent to simply using the asynchronous API —
that's how the asynchronous API is implemented.

The rest of this chapter sticks to the asynchronous API.

Reading/writing files
---------------------

A file descriptor is obtained by calling :api:`Luv.File.open_
<File/index.html#val-open_>`:

.. code-block:: ocaml

    Luv.File.open_ :
      ?mode:Luv.File.Mode.t list ->
      string ->
      Luv.File.Open_flag.t list ->
      ((Luv.File.t, Luv.Error.t) result -> unit) ->
        unit

Despite the verbose signature, usage is simple:

.. code-block:: ocaml

    Luv.File.open_ "foo" [`RDONLY] (fun result -> (* ... *))

:api:`Luv.File.Open_flag.t <File/Open_flag/index.html#type-t>` and
:api:`Luv.File.Mode.t <File/Mode/index.html#type-t>` expose the standard Unix
open flags and file modes, respectively. libuv takes care of converting them to
appropriate values on Windows. ``mode`` is optional, because it is only used if
``open_`` creates the file.

File descriptors are closed using :api:`Luv.File.close
<File/index.html#val-close>`:

.. code-block:: ocaml

    Luv.File.close : Luv.File.t -> ((unit, Luv.Error.t) result -> unit) -> unit

Finally, reading and writing are done with :api:`Luv.File.read
<File/index.html#val-read>` and :api:`Luv.File.write
<File/index.html#val-write>`:

.. code-block:: ocaml

    Luv.File.read :
      Luv.File.t ->
      Luv.Buffer.t list ->
      ((Unsigned.Size_t.t, Luv.Error.t) result -> unit) ->
        unit

    Luv.File.write :
      Luv.File.t ->
      Luv.Buffer.t list ->
      ((Unsigned.Size_t.t, Luv.Error.t) result -> unit) ->
        unit

Let's put all this together into a simple implementation of ``cat``:

.. rubric:: :example:`cat.ml`
.. literalinclude:: ../example/cat.ml
    :language: ocaml
    :linenos:
    :emphasize-lines: 2,8,16-19,21,25,29

.. note::

    ``on_write`` is not robust, because we don't check that the number of bytes
    written is actually the number of bytes we requested to write. Fewer bytes
    could have been written, in which case we would need to try again to write
    the remaining bytes.

.. warning::

    Due to the way filesystems and disk drives are configured for performance,
    a write that succeeds may not be committed to disk yet.

Filesystem operations
---------------------

All the standard filesystem operations like ``unlink``, ``rmdir``, ``stat`` are
supported both synchronously and asynchronously. The easiest way to see the full
list, with simplified signatures, is to scroll down through :api:`Luv.File.Sync
<File/Sync/index.html>`.

File change events
------------------

All modern operating systems provide APIs to put watches on individual files or
directories and be informed when the files are modified. libuv wraps common
file change notification libraries [#fsnotify]_, and the wrapper is exposed by
Luv as module :api:`Luv.FS_event <FS_event/index.html>`. To demonstrate, let's
build a simple utility which runs a command whenever any of the watched files
change::

    ./onchange <command> <file1> [file2] ...

.. rubric:: :example:`onchange.ml`
.. literalinclude:: ../example/onchange.ml
    :language: ocaml
    :linenos:
    :emphasize-lines: 10,18,20,24

----

.. [#fsnotify] inotify on Linux, FSEvents on Darwin, kqueue on BSDs,
               ReadDirectoryChangesW on Windows, event ports on Solaris. Unsupported on Cygwin
