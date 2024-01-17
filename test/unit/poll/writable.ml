let () =
  Helpers.with_poll @@ fun poll ->

  Luv.Poll.start poll [`WRITABLE] begin fun result ->
    result |> ok "poll" @@ fun status ->
    List.mem `WRITABLE status |> Printf.printf "%b\n";
    Luv.Poll.stop poll |> ok "stop" ignore
  end;

  Luv.Loop.run () |> ignore;
  print_endline "Ok"
