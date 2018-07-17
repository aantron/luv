(* TODO Clean up. *)

(* TODO Shouldn't really be raising Failure, but oh well. *)
(* TODO Move these helpers into the library? *)
let fail error_code =
  raise (Failure (Luv.Error.strerror error_code))

let check error_code =
  if error_code <> Luv.Error.Code.success then
    fail error_code

let () =
  (* TODO Once libuv DNS is implemented, use it here. *)
  let google =
    Unix.getaddrinfo "google.com" "80" []
    |> List.hd
    |> fun address -> Unix.(address.ai_addr)
  in

  let client =
    match Luv.TCP.init () with
    | Ok stream -> stream
    | Error error_code -> fail error_code
  in

  check @@ Luv.TCP.connect client google ~callback:begin fun _ error_code ->
    check error_code;

    (* TODO Add Bigstring.from_string as a helper in Luv.Bigstring. *)
    (* TODO Also need Bigstring init functions? *)
    let request_string =
      "GET / HTTP/1.1\r\n" ^
      "Connection: close\r\n\r\n"
    in
    let request =
      Bigarray.(Array1.create Char C_layout (String.length request_string)) in
    String.iteri (Bigarray.Array1.set request) request_string;

    check @@ Luv.Stream.write client [request]
        ~callback:begin fun _ error_code ->
      check error_code;

      check @@ Luv.Stream.read_start client
          ~allocate:(fun _ -> Luv.Bigstring.create)
          ~callback:begin fun _ result ->
        match result with
        | Error code ->
          if code = Luv.Error.Code.eof then
            Luv.Handle.close client
          else
            fail code
        | Ok (buffer, length) ->
          for index = 0 to length - 1 do
            print_char (Bigarray.Array1.get buffer index)
          done
      end
    end
  end;

  ignore @@ Luv.Loop.(run (default ()) Run_mode.default)
