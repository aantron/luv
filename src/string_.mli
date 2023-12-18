(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



val utf16_length_as_wtf8 : string -> int
(** Binds {{:https://docs.libuv.org/en/v1.x/misc.html#c.uv_utf16_length_as_wtf8}
    [uv_utf16_length_as_wtf8]}.

    Requires Luv 0.5.13 and libuv 1.47.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has utf_16)] *)

val utf16_to_wtf8 : string -> string
(** Binds {{:https://docs.libuv.org/en/v1.x/misc.html#c.uv_utf16_to_wtf8}
    [uv_utf16_to_wtf8]}.

    Requires Luv 0.5.13 and libuv 1.47.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has utf_16)] *)

val wtf8_length_as_utf16 : string -> int
(** Binds {{:https://docs.libuv.org/en/v1.x/misc.html#c.uv_wtf8_length_as_utf16}
    [uv_wtf8_length_as_utf16]}.

    Requires Luv 0.5.13 and libuv 1.47.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has utf_16)] *)

val wtf8_to_utf16 : string -> string
(** Binds {{:https://docs.libuv.org/en/v1.x/misc.html#c.uv_wtf8_to_utf16}
    [uv_wtf8_to_utf16]}.

    Requires Luv 0.5.13 and libuv 1.47.0.

    {{!Luv.Require} Feature check}: [Luv.Require.(has utf_16)] *)
