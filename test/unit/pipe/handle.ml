(* This is a compilation test. If the type constraints in handle.mli are wrong,
   there will be a type error in this test. *)
let () =
  Helpers.with_pipe begin fun pipe ->
    ignore @@ Luv.Handle.send_buffer_size pipe;
    ignore @@ Luv.Handle.recv_buffer_size pipe;
    ignore @@ Luv.Handle.set_send_buffer_size pipe 4096;
    ignore @@ Luv.Handle.set_recv_buffer_size pipe 4096;
    ignore @@ Luv.Handle.fileno pipe
  end;

  print_endline "Ok"
