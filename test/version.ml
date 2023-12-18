(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let tests = [
  "version", [
    "major", `Quick, (fun () ->
      Alcotest.(check int) "number" 1 Luv.Version.major);

    "minor", `Quick, (fun () ->
      Alcotest.(check int) "number" 47 Luv.Version.minor);

    "patch", `Quick, (fun () ->
      Alcotest.(check int) "number" 0 Luv.Version.patch);

    "is_release", `Quick, (fun () ->
      Alcotest.(check bool) "value" true Luv.Version.is_release);

    "suffix", `Quick, (fun () ->
      Alcotest.(check string) "suffix" "" Luv.Version.suffix);

    "hex", `Quick, (fun () ->
      Alcotest.(check int) "number" 0x012F00 Luv.Version.hex);

    "version", `Quick, (fun () ->
      Alcotest.(check int) "number" 0x012F00 (Luv.Version.version ()));

    "string", `Quick, (fun () ->
      Alcotest.(check string) "value" "1.47.0" (Luv.Version.string ()));
  ]
]
