(* TODO Move this stuff into an examples helper module, and document there why
   this kind of error handling is not suitable for production. *)
let fail error_code =
  raise (Failure (Luv.Error.strerror error_code))

let check error_code =
  if error_code <> Luv.Error.Code.success then
    fail error_code

(* TODO Usage instructions with jbuilder and netcat. *)

let () =
  let server =
    match Luv.TCP.init () with
    | Ok server -> server
    | Error error_code -> fail error_code
  in

  check @@ Luv.TCP.bind server Unix.(ADDR_INET (inet_addr_loopback, 5000));

  check @@ Luv.Stream.listen ~backlog:5 server ~callback:begin fun _ result ->
    check result;

    let remote_client =
      match Luv.Stream.accept server with
      | Ok remote_client -> remote_client
      | Error error_code -> fail error_code
    in

    let rec echo_loop () =
      (* TODO Syntax cleanup. *)
      check @@ Luv.Stream.read_start remote_client
          ~allocate:(fun _ -> Luv.Bigstring.create)
          ~callback:begin fun _ result ->

        match result with
        | Error error_code ->
          if error_code = Luv.Error.Code.eof then
            Luv.Handle.close remote_client
          else
            fail error_code

        | Ok (buffer, length) ->
          (* TODO Is there a 0-copy way of referencing the subarray? At the
            very least, Lwt seems to provide a way of doing this. Also, does
            the memory need to be retained during the write call? *)
          check @@ Luv.Stream.read_stop remote_client;

          let subarray = Bigarray.Array1.sub buffer 0 length in
          check @@ Luv.Stream.write remote_client [subarray]
              ~callback:begin fun _ result ->
            check result;
            echo_loop ()
          end
        end
    in
    echo_loop ()
  end;

  ignore @@ Luv.Loop.(run (default ()) Run_mode.default)
