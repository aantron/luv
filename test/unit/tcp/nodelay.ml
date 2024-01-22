let () =
  Helpers.with_tcp @@ fun tcp ->

  Luv.TCP.nodelay tcp true |> ok "nodelay" @@ fun () ->

  print_endline "Ok"
