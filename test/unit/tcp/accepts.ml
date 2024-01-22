let () =
  Helpers.with_tcp @@ fun tcp ->

  Luv.TCP.simultaneous_accepts tcp true |> ok "accepts" @@ fun () ->

  print_endline "Ok"
