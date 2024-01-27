let () =
  Luv.Error.set_on_unhandled_exception (function
    | Exit -> print_endline "Ok"
    | _ -> ());

  Helpers.with_sender_and_receiver
    ~port:5204
    ~sender:begin fun sender_udp address ->
      let b = Luv.Buffer.from_string "foo" in
      Luv.UDP.send sender_udp [b] address @@ fun result ->
      result |> ok "send" @@ fun () ->
      raise Exit
    end
    ~receiver:begin fun receiver_udp ->
      Luv.Handle.close receiver_udp ignore
    end
