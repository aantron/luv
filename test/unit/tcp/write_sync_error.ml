let () =
  Helpers.with_tcp @@ fun tcp ->

  Luv.Stream.write tcp [Luv.Buffer.from_string ""] begin fun result count ->
    result |> error [`EBADF; `EPIPE] "write" @@ fun () ->
    Printf.printf "%i\n" count
  end
