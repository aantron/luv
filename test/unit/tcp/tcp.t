  $ dune exec ./trivial.exe
  Ok

  $ dune exec ./nodelay.exe
  Ok

  $ dune exec ./keepalive.exe
  Ok

  $ dune exec ./accepts.exe
  Ok

  $ dune exec ./bind.exe
  Ok

  $ dune exec ./getsockname.exe
  true

  $ dune exec ./econnrefused.exe
  Ok

  $ dune exec ./connect_gc.exe
  Ok

  $ dune exec ./connect_leak.exe
  End

  $ dune exec ./connect_sync_error.exe
  Ok

  $ dune exec ./connect_sync_error_leak.exe
  End

  $ dune exec ./connect_cancel.exe
  Ok

  $ dune exec ./listen_accept.exe
  Accepted
  Connected

  $ dune exec ./getpeername.exe
  true
