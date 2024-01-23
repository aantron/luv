(* This is a compilation test. If the type constraints in handle.mli are wrong,
   there will be a type error in this test. *)
let () =
  Helpers.with_tcp begin fun tcp ->
    ignore @@ Luv.Handle.send_buffer_size tcp;
    ignore @@ Luv.Handle.recv_buffer_size tcp;
    ignore @@ Luv.Handle.set_send_buffer_size tcp 4096;
    ignore @@ Luv.Handle.set_recv_buffer_size tcp 4096;
    ignore @@ Luv.Handle.fileno tcp
  end;

  print_endline "Ok"
