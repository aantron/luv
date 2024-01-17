let with_poll f =
  Luv.TCP.socketpair `STREAM 0 |> ok "socketpair" @@ fun (socket_1, _) ->
  Luv.Poll.init_socket socket_1 |> ok "init_socket" @@ fun poll ->
  f poll;
  Luv.Handle.close poll ignore
