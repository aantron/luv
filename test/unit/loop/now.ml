let () =
  Helpers.with_loop @@ fun loop ->
  let time = Luv.Loop.now loop in
  if Unsigned.UInt64.(compare time zero) <= 0 then
    print_endline "Error: negative time"
  else
    print_endline "Ok"
