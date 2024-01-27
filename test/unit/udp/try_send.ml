let () =
  Helpers.with_sender_and_receiver
    ~port:5203
    ~sender:begin fun sender_udp address ->
      let b = Luv.Buffer.from_string "foo" in
      Luv.UDP.try_send sender_udp [b] address |> ok "send" @@ fun () ->
      Luv.Handle.close sender_udp ignore
    end
    ~receiver:begin fun receiver_udp ->
      Helpers.recv receiver_udp @@ fun () ->
      Luv.Handle.close receiver_udp ignore
    end
