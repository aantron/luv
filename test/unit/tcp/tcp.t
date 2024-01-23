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

  $ dune exec ./listen_exception.exe
  Ok

  $ dune exec ./connect_exception.exe
  Ok

  $ dune exec ./read_write.exe
  false true false
  3
  "foo"
  true true true

  $ dune exec ./eof.exe
  Ok

  $ dune exec ./write_sync_error.exe
  0

  $ dune exec ./write_sync_error_leak.exe
  End

  $ dune exec ./read_exception.exe
  1
  Ok

  $ dune exec ./write_exception.exe
  Ok

  $ dune exec ./try_write.exe
  3
  "foo"

  $ dune exec ./try_write_error.exe
  Ok

  $ dune exec ./shutdown.exe
  Server ok
  Client ok

  $ dune exec ./shutdown_sync_error.exe
  Ok

  $ dune exec ./shutdown_sync_error_leak.exe
  End

  $ dune exec ./shutdown_exception.exe
  Ok

  $ dune exec ./close_reset_sync_error.exe
  Ok

  $ dune exec ./close_reset.exe
  Ok

  $ dune exec ./handle.exe
  Ok

  $ dune exec ./socketpair.exe
  "foo"
