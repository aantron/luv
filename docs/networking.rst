Networking
==========

The overall flow of network programming in libuv (and Luv) is very similar to
the BSD socket interface, but all functions take callbacks, and many
inconveniences are addressed.

Networking is handled by :api:`Luv.TCP <TCP/index.html>`, :api:`Luv.UDP
<UDP/index.html>`, and :api:`Luv.DNS <DNS/index.html>`.

.. note::

  The code examples in this chapter exist to demonstrate certain Luv APIs. They
  are not always robust. For instance, they don't always close connections
  properly, and they don't handle all errors gracefully.

.. _TCP:

TCP
---

TCP is a connection-oriented stream protocol. TCP handles are therefore a kind
of libuv *stream*. All this means is that a :api:`Luv.TCP.t
<TCP/index.html#type-t>` is also a :api:`Luv.Stream.t
<Stream/index.html#type-t>`, which, in turn, is also a :api:`Luv.Handle.t
<Handle/index.html#type-t>`. So, functions from all three modules can be used
with :api:`Luv.TCP.t <TCP/index.html#type-t>`. In particular, you will typically
use...

- :api:`Luv.TCP <TCP/index.html>` to initialize a TCP socket handle.
- :api:`Luv.Stream <Stream/index.html>` to do I/O on the socket.
- :api:`Luv.Handle.close <Handle/index.html#val-close>` to close the socket.

Server
++++++

A server socket is typically...

1. Created with :api:`Luv.TCP.init <TCP/index.html#val-init>`.
2. Assigned an address with :api:`Luv.TCP.bind <TCP/index.html#val-bind>`.
3. Made to listen on the assigned address with :api:`Luv.Stream.listen
   <Stream/index.html#val-listen>`. This will call its callback each time there
   is a client connection ready to be accepted.
4. Told to accept a connection with :api:`Luv.Stream.accept
   <Stream/index.html#val-accept>`.

After that, one has an ordinary TCP connection. :api:`Luv.Stream.read_start
<Stream/index.html#val-read_start>` and :api:`Luv.Stream.write
<Stream/index.html#val-write>` are used to communicate on it, and
:api:`Luv.Handle.close <Handle/index.html#val-close>` is used to close it.

Here is a simple echo server that puts all this together:

.. rubric:: :example:`tcp_echo_server.ml`
.. literalinclude:: ../example/tcp_echo_server.ml
    :language: ocaml
    :linenos:
    :emphasize-lines: 4,6,12,17,24

The most interesting thing to note is that :api:`Luv.Stream.read_start
<Stream/index.html#val-read_start>` doesn't perform only one read, but reads in
a loop until either :api:`Luv.Stream.read_stop
<Stream/index.html#val-read_stop>` is called, or the socket is closed.

Client
++++++

Client programming is very straightforward: use :api:`Luv.TCP.connect
<TCP/index.html#val-connect>` to establish a connection. Then, use
:api:`Luv.Stream.write <Stream/index.html#val-write>` and
:api:`Luv.Stream.read_start <Stream/index.html#val-read_start>` to communicate.

The example below sends "Hello, world!" to the echo server, waits for the
response, and prints it:

.. rubric:: :example:`tcp_hello_world.ml`
.. literalinclude:: ../example/tcp_hello_world.ml
    :language: ocaml
    :linenos:
    :emphasize-lines: 5,10,11,13

You can run the above server and this client together with these commands:

.. code-block::

    dune exec example/tcp_echo_server.exe &
    dune exec example/tcp_hello_world.exe
    killall tcp_echo_server.exe

In the DNS_ section below, we will expand this example to look up a web server
and perform an HTTP GET request.

UDP
---

UDP_ is a connectionless protocol. Rather than behaving as a stream, a UDP
socket allows sending and receiving discrete *datagrams*. So, in Luv (as in
libuv), a :api:`Luv.UDP.t <UDP/index.html#type-t>` is *not* a
:api:`Luv.Stream.t <Stream/index.html#type-t>`. It does, however, have similar
functions :api:`Luv.UDP.send <UDP/index.html#val-send>` and
:api:`Luv.UDP.recv_start <UDP/index.html#val-recv_start>`. A :api:`Luv.UDP.t
<UDP/index.html#type-t>` is still a :api:`Luv.Handle.t
<Handle/index.html#type-t>`, however, so a UDP socket is closed with
:api:`Luv.Handle.close <Handle/index.html#val-close>`.

.. _UDP: https://en.wikipedia.org/wiki/User_Datagram_Protocol

Let's write UDP versions of the echo server and the "Hello, world!" program:

.. rubric:: :example:`udp_echo_server.ml`
.. literalinclude:: ../example/udp_echo_server.ml
    :language: ocaml
    :linenos:
    :emphasize-lines: 4,6,12

.. rubric:: :example:`udp_hello_world.ml`
.. literalinclude:: ../example/udp_hello_world.ml
    :language: ocaml
    :linenos:
    :emphasize-lines: 6,8

You can run the client and the server together with:

.. code-block::

    dune exec example/udp_echo_server.exe &
    dune exec example/udp_hello_world.exe
    killall udp_echo_server.exe

The two most immediate differences, compared to the TCP functions, are:

1. There are no notions of listening or connecting.
2. Since there is no connection, when data is received by
   :api:`Luv.UDP.recv_start <UDP/index.html#val-recv_start>`, the sending peer's
   address is provided to the callback together with the data.

Apart from ordinary peer-to-peer communication, UDP supports multicast. See
:api:`Luv.UDP <UDP/index.html>` for multicast and other helper functions.

.. _DNS:

Querying DNS
------------

libuv provides asynchronous DNS resolution with :api:`Luv.DNS.getaddrinfo
<DNS/index.html#val-getaddrinfo>`. Let's implement a clone of the ``host``
command:

.. rubric:: :example:`host.ml`
.. literalinclude:: ../example/host.ml
    :language: ocaml
    :linenos:

:api:`Luv.DNS.getaddrinfo <DNS/index.html#val-getaddrinfo>` has a large number
of optional arguments for fine-tuning the lookup. These correspond to the fields
and flags documented at :man:`getaddrinfo(3p) <3/getaddrinfo.3p>`.

libuv also provides reverse lookup, which is exposed as
:api:`Luv.DNS.getnameinfo <DNS/index.html#val-getnameinfo>`.

Example: HTTP GET
-----------------

We can use :api:`Luv.TCP <TCP/index.html>` and :api:`Luv.DNS <DNS/index.html>`
to run fairly complete HTTP GET requests:

.. rubric:: :example:`http_get.ml`
.. literalinclude:: ../example/http_get.ml
    :language: ocaml
    :linenos:
    :emphasize-lines: 5,12,19,21,22,24,31

You can try this in the Luv repo with the command::

    dune exec example/http_get.exe -- google.com /

Network interfaces
------------------

Information about the system's network interfaces can be obtained by calling
:api:`Luv.Network.interface_addresses
<Network/index.html#val-interface_addresses>`. This simple program prints out
all the interface details made available by libuv:

.. rubric:: :example:`ifconfig.ml`
.. literalinclude:: ../example/ifconfig.ml
    :language: ocaml
    :linenos:

``is_internal`` is true for loopback interfaces. Note that if an interface has
multiple addresses (for example, an IPv4 address and an IPv6 address), the
interface will be reported multiple times, once with each address.
