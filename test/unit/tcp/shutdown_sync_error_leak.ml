let () =
  Helpers.with_tcp @@ fun tcp ->

  no_memory_leak begin fun _n ->
    let callback = fresh_callback () in
    Luv.Stream.shutdown tcp (fun _ -> callback ());
    Luv.Loop.run () |> ignore
  end;

  print_endline "End"
