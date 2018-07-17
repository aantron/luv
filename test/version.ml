let tests = [
  "version", [
    "major", `Quick, (fun () ->
      Alcotest.(check int) "number" 1 Luv.Version.major);

    "minor", `Quick, (fun () ->
      Alcotest.(check int) "number" 20 Luv.Version.minor);

    "patch", `Quick, (fun () ->
      Alcotest.(check int) "number" 3 Luv.Version.patch);

    "is_release", `Quick, (fun () ->
      Alcotest.(check bool) "value" true Luv.Version.is_release);

    (* TODO Suffix test. *)

    "hex", `Quick, (fun () ->
      Alcotest.(check int) "number" 0x011403 Luv.Version.hex);

    "version", `Quick, (fun () ->
      Alcotest.(check int) "number" 0x011403 (Luv.Version.version ()));

    "string", `Quick, (fun () ->
      Alcotest.(check string) "value" "1.20.3" (Luv.Version.string ()));
  ]
]