let () =
  let b1_finalized = ref false in
  let b2_finalized = ref false in
  let b3_finalized = ref false in

  Helpers.with_server_and_client
    ~port:5112
    ~server:begin fun server_tcp accept_tcp ->
      Luv.Stream.read_start accept_tcp begin fun result ->
        result |> ok "read_start" @@ fun b ->
        Printf.printf "%S\n" (Luv.Buffer.to_string b);
        Luv.Handle.close accept_tcp ignore;
        Luv.Handle.close server_tcp ignore
      end
    end
    ~client:begin fun client_tcp _ ->
      let b1 = Luv.Buffer.from_string "fo" in
      let b2 = Luv.Buffer.from_string "nop" in
      let b3 = Luv.Buffer.sub b2 ~offset:1 ~length:1 in

      b1 |> Gc.finalise (fun _ -> b1_finalized := true);
      b2 |> Gc.finalise (fun _ -> b2_finalized := true);
      b3 |> Gc.finalise (fun _ -> b3_finalized := true);

      Luv.Stream.write client_tcp [b1; b3] begin fun result count ->
        Luv.Handle.close client_tcp ignore;
        result |> ok "write" @@ fun () ->
        Printf.printf "%i\n" count
      end;

      Gc.full_major ();
      Printf.printf "%b %b %b\n" !b1_finalized !b2_finalized !b3_finalized
    end;

  Gc.full_major ();
  Printf.printf "%b %b %b\n" !b1_finalized !b2_finalized !b3_finalized
