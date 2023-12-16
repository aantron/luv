(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let tests = [
  "string", [
    "utf16_length_as_wtf8", `Quick, begin fun () ->
      Luv.String.utf16_length_as_wtf8 "f\x00\xBB\x03"
      |> Alcotest.(check int) "length" 3
    end;

    "utf16_to_wtf8", `Quick, begin fun () ->
      Luv.String.utf16_to_wtf8 "f\x00\xBB\x03"
      |> Alcotest.(check string) "value" "fλ"
    end;

    "wtf8_length_as_utf16", `Quick, begin fun () ->
      Luv.String.wtf8_length_as_utf16 "fλ"
      |> Alcotest.(check int) "length" 3
    end;

    "wtf8_to_utf16", `Quick, begin fun () ->
      Luv.String.wtf8_to_utf16 "fλ"
      |> Alcotest.(check string) "value" "f\x00\xBB\x03"
    end;
  ]
]
