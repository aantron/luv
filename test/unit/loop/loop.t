  $ dune exec ./trivial.exe
  Ok

  $ dune exec ./configure.exe
  Ok

  $ dune exec ./configure_invalid.exe
  Ok

  $ dune exec ./default.exe
  false

  $ dune exec ./run_empty_default.exe
  false

  $ dune exec ./run_empty_once.exe
  false

  $ dune exec ./run_empty_nowait.exe
  false

  $ dune exec ./alive.exe
  false

  $ dune exec ./stop.exe
  Ok

  $ dune exec ./backend_fd.exe
  Ok

  $ dune exec ./backend_timeout.exe
  0

  $ dune exec ./now.exe
  Ok

  $ dune exec ./update_time.exe
  Ok
