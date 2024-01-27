  $ dune exec ./trivial.exe
  Ok

  $ dune exec ./bind.exe
  Ok

  $ dune exec ./listen_accept.exe
  Accepted

  $ dune exec ./getsockname.exe
  true

  $ dune exec ./getpeername.exe
  true

  $ dune exec ./connect_exception.exe
  Ok

  $ dune exec ./receive_handle.exe
  3
  "foo"
  Ok

  $ dune exec ./chmod.exe
  Ok

  $ dune exec ./chmod_error.exe
  Ok

  $ dune exec ./handle.exe
  Ok
