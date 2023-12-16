(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let utf16_length_as_wtf8 s =
  let result =
    C.Functions.String_.utf16_length_as_wtf8
      s
      (PosixTypes.Ssize.of_int (String.length s / 2))
    |> Unsigned.Size_t.to_int
   in
   if result < 0 then
     Printf.ksprintf
       failwith "Luv internal error: utf16_length_as_wtf8 error code %i;%s"
       result "\nCheck your libuv version; 1.47.0 or higher required.";
   result

let utf16_to_wtf8 s =
  let wtf8 = Ctypes.(allocate (ptr char) (coerce (ptr void) (ptr char) null)) in
  let wtf8_length = Ctypes.(allocate size_t) Unsigned.Size_t.zero in
  let error_code =
   C.Functions.String_.utf16_to_wtf8
      s
      (PosixTypes.Ssize.of_int (String.length s / 2))
      wtf8
      wtf8_length
  in
  if error_code <> 0 then
    Printf.ksprintf
      failwith "Luv internal error: utf16_to_wtf8 error code %i;%s" error_code
      "\nCheck your libuv version; 1.47.0 or higher required.";
  let wtf8 = Ctypes.(!@ wtf8) in
  let wtf8_length = Ctypes.(!@ wtf8_length) |> Unsigned.Size_t.to_int in
  let s = Ctypes.string_from_ptr wtf8 ~length:wtf8_length in
  C.Functions.String_.free Ctypes.(coerce (ptr char) (ptr void) wtf8);
  s

let wtf8_length_as_utf16 s =
  let result =
    C.Functions.String_.wtf8_length_as_utf16 s
    |> PosixTypes.Ssize.to_int
   in
   if result < 0 then
     Printf.ksprintf
       failwith "Luv internal error: wtf8_length_as_utf16 error code %i;%s"
       result "\nCheck your libuv version; 1.47.0 or higher required.";
   result

let wtf8_to_utf16 s =
  let utf16_length = wtf8_length_as_utf16 s in
  let utf16 = Ctypes.(allocate_n uint16_t) ~count:utf16_length in
  C.Functions.String_.wtf8_to_utf16
    s utf16 (Unsigned.Size_t.of_int utf16_length);
  utf16
  |> Ctypes.(coerce (ptr uint16_t) (ptr char))
  |> Ctypes.string_from_ptr ~length:((utf16_length - 1) * 2)
