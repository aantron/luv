Introduction
============

Running the examples
--------------------

All the examples in this guide can be found in the ``example/`` directory in the
Luv_ repo. You can run them locally by cloning the repo::

    git clone https://github.com/aantron/luv.git --recursive
    cd luv

and then running ``make examples``. Note the examples require OCaml 4.08 or
higher.

To run a specific example, say, ``delay.ml``, run::

    dune exec example/delay.exe

You can also pass arguments to examples with this syntax:

.. code-block::

    dune exec example/http_get.exe -- google.com /

Using the repo for experiments
------------------------------

You can quickly experiment with Luv by writing your own code in ``example/``.
Let's say you add a file, ``example/test.ml``. Add it to the ``names`` list in
``example/dune``:

.. code-block::
    :emphasize-lines: 6

    (executables
     (names
      hello_world
      ; ...
      sigint
      test)     ; <-- here!
     (libraries luv))

...and then run it like any other example:

.. code-block::

    dune exec example/my_test.exe

If you have utop_ installed, you can also run::

    dune utop

inside the Luv repo, to access the Luv API in a REPL. For example, try
``dune utop``, and, when you get the REPL prompt, run ``Luv.Env.environ ();;``

.. _Luv: https://github.com/aantron/luv
.. _utop: https://github.com/ocaml-community/utop
