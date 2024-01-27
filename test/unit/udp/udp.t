  $ dune exec ./trivial.exe
  Ok

  $ dune exec ./bind.exe
  Ok

  $ dune exec ./getsockname.exe
  true

  $ dune exec ./send_recv.exe
  "foo"

  $ dune exec ./try_send.exe
  "foo"

  $ dune exec ./send_exception.exe
  Ok

  $ dune exec ./recv_exception.exe
  "foo"
  Ok

  $ dune exec ./empty.exe
  ""

  $ dune exec ./connect_getpeername.exe
  true
  Ok

  $ dune exec ./double_connect.exe
  Ok

  $ dune exec ./initial_disconnect.exe
  Ok

  $ dune exec ./connected_send.exe
  "foo"

  $ dune exec ./connected_try_send.exe
  "foo"

  $ dune exec ./handle.exe
  Ok
