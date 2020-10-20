external retrieve_constant : unit -> int = "retrieve_constant"

let () =
  Printf.eprintf "UV_EBADF = %i\n" (retrieve_constant ());
  prerr_endline "Depending on libuv headers works."
