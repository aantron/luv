let () =
  Helpers.with_sender_and_receiver
    ~port:5211
    ~sender:begin fun sender_udp address ->
      Luv.UDP.Connected.connect sender_udp address |> ok "connect" @@ fun () ->
      let b = Luv.Buffer.from_string "foo" in
      Luv.UDP.Connected.send sender_udp [b] @@ fun result ->
      result |> ok "send" @@ fun () ->
      Luv.Handle.close sender_udp ignore
    end
    ~receiver:begin fun receiver_udp ->
      Helpers.recv receiver_udp @@ fun () ->
      Luv.Handle.close receiver_udp ignore
    end
