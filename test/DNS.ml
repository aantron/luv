(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



open Test_helpers

let tests = [
  "dns", [
    "getaddrinfo", `Quick, begin fun () ->
      let resolved = ref false in

      Luv.DNS.Async.getaddrinfo ~family:`INET ~node:"localhost" ()
          begin fun result ->

        match check_success_result "getaddrinfo" result with
        | [] -> Alcotest.fail "none"
        | first::_ ->
          if first.family <> `INET then
            Alcotest.fail "expected family `INET";
          Alcotest.(check (option string)) "canonname" None first.canonname;
          Alcotest.(check string) "address"
            "127.0.0.1" (Luv.Sockaddr.to_string first.addr);
          resolved := true
      end;

      run ();

      Alcotest.(check bool) "resolved" true !resolved
    end;

    "getnameinfo", `Quick, begin fun () ->
      let address =
        Luv.Sockaddr.ipv4 "127.0.0.1" 0 |> check_success_result "ipv4" in
      let resolved = ref false in

      Luv.DNS.Async.getnameinfo address begin fun result ->
        check_success_result "getnameinfo" result
        |> fst
        |> Alcotest.(check string) "host" "localhost";
        resolved := true
      end;

      run ();

      Alcotest.(check bool) "resolved" true !resolved
    end;
  ]
]
