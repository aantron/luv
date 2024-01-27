let with_udp f =
  Luv.UDP.init () |> ok "init" @@ fun udp ->
  f udp;
  Luv.Handle.close udp ignore

let with_sender_and_receiver ~port ~sender ~receiver =
  Luv.Sockaddr.ipv4 "127.0.0.1" port |> ok "ipv4" @@ fun address ->

  Luv.UDP.init () |> ok "receiver init" @@ fun receiver_udp ->
  Luv.UDP.bind receiver_udp address |> ok "bind" @@ fun () ->

  Luv.UDP.init () |> ok "sender init" @@ fun sender_udp ->

  receiver receiver_udp;
  sender sender_udp address;

  Luv.Loop.run () |> ignore

let recv receiver_udp k =
  Luv.UDP.recv_start receiver_udp begin fun result ->
    result |> ok "recv_start" @@ fun (buffer, _, flags) ->
    if flags <> [] then
      print_endline "Partial recv";
    Printf.printf "%S\n" (Luv.Buffer.to_string buffer);
    Luv.UDP.recv_stop receiver_udp |> ok "recv_stop" k
  end
