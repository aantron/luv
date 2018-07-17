let tests = [
  "request", [
    "type", `Quick, begin fun () ->
      let open Luv.Request.Type in
      Alcotest.(check int) "req" 1 (req :> int);
      Alcotest.(check int) "connect" 2 (connect :> int);
      Alcotest.(check int) "write" 3 (write :> int);
      Alcotest.(check int) "shutdown" 4 (shutdown :> int);
      Alcotest.(check int) "udp_send" 5 (udp_send :> int);
      Alcotest.(check int) "fs" 6 (fs :> int);
      Alcotest.(check int) "work" 7 (work :> int);
      Alcotest.(check int) "getaddrinfo" 8 (getaddrinfo :> int);
      Alcotest.(check int) "getnameinfo" 9 (getnameinfo :> int);
    end;

    "name", `Quick, begin fun () ->
      let t name type_ =
        Alcotest.(check string) name name (Luv.Request.type_name type_)
      in
      let open Luv.Request.Type in
      t "req" req;
      t "connect" connect;
      t "write" write;
      t "shutdown" shutdown;
      t "udp_send" udp_send;
      t "fs" fs;
      t "work" work;
      t "getaddrinfo" getaddrinfo;
      t "getnameinfo" getnameinfo;
    end;

    "data", `Quick, begin fun () ->
      let data = 42 in
      let request = Ctypes.make Luv.Request.t in

      data
      |> Nativeint.of_int
      |> Ctypes.ptr_of_raw_address
      |> Luv.Request.set_data (Ctypes.addr request);

      Luv.Request.get_data (Ctypes.addr request)
      |> Ctypes.raw_address_of_ptr
      |> Nativeint.to_int
      |> Alcotest.(check int) "value" data
    end;
  ]
]
