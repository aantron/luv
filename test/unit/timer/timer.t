  $ dune exec ./trivial.exe
  Ok

  $ dune exec ./loop.exe
  true

  $ dune exec ./start.exe
  Ok

  $ dune exec ./double_start.exe
  Second

  $ dune exec ./repeated_start_leak.exe
  End

  $ dune exec ./stop.exe
  Ok

  $ dune exec ./again.exe
  Called

  $ dune exec ./close_leak.exe
  End

  $ dune exec ./double_close.exe
  End

  $ dune exec ./multithreading.exe
  Main thread
  Worker thread
  true

  $ dune exec ./busywait_deadlock.exe
  Ok

  $ dune exec ./exception.exe
  Ok

  $ dune exec ./is_active.exe
  false
  true

  $ dune exec ./is_closing.exe
  false
  true
  true

  $ dune exec ./ref.exe
  true
  true
  false
  false
