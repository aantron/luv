  $ dune exec ./idle_trivial.exe
  Ok

  $ dune exec ./idle_loop.exe
  true

  $ dune exec ./idle_start_stop.exe
  Idle
  Idle
  Ok

  $ dune exec ./idle_double_start.exe
  First
  First

  $ dune exec ./idle_exception.exe
  Ok

  $ dune exec ./check_trivial.exe
  Ok

  $ dune exec ./check_loop.exe
  true

  $ dune exec ./check_start_stop.exe
  Check
  Check
  Ok

  $ dune exec ./check_double_start.exe
  First
  First

  $ dune exec ./check_exception.exe
  Ok

  $ dune exec ./prepare_trivial.exe
  Ok

  $ dune exec ./prepare_loop.exe
  true

  $ dune exec ./prepare_start_stop.exe
  Prepare
  Prepare
  Ok

  $ dune exec ./prepare_double_start.exe
  First
  First

  $ dune exec ./prepare_exception.exe
  Ok
