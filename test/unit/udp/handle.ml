(* This is a compilation test. If the type constraints in handle.mli are wrong,
   there will be a type error in this test. *)
let () =
  Helpers.with_udp begin fun udp ->
    ignore @@ Luv.Handle.send_buffer_size udp;
    ignore @@ Luv.Handle.recv_buffer_size udp;
    ignore @@ Luv.Handle.set_send_buffer_size udp 4096;
    ignore @@ Luv.Handle.set_recv_buffer_size udp 4096;
    ignore @@ Luv.Handle.fileno udp
  end;

  print_endline "Ok"
