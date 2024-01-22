(* Fails with a segfault if the binding doesn't retain a reference to the
   callback. *)
let () =
  Helpers.with_tcp @@ fun tcp ->

  Luv.Sockaddr.ipv4 "127.0.0.1" 5103 |> ok "ipv4" @@ fun address ->
  Luv.TCP.connect tcp address (fun _ -> print_endline "Ok");

  Gc.full_major ();

  Luv.Loop.run () |> ignore
