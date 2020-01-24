(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Data buffers. *)



(** {1 Basics} *)

type t = (char, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t
(** Buffers with C storage.

    These are OCaml bigstrings ([char] bigarrays). Roughly speaking, they
    correspond to C buffers referenced by pointers of type [char*], but also
    know their own size.

    In addition to being usable with the functions in this module, the type is
    compatible with at least the following libraries:

    - {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Bigarray.Array1.html}
      [Bigarray]} from OCaml's standard library
    - {{:https://ocsigen.org/lwt/dev/api/Lwt_bytes} [Lwt_bytes]} from Lwt
    - {{:https://github.com/inhabitedtype/bigstringaf} bigstringaf}
    - {{:https://github.com/c-cube/ocaml-bigstring} ocaml-bigstring} *)

val create : int -> t
(** Allocates a fresh buffer of the given size. *)

val size : t -> int
(** Evaluates to the size of the given buffer. *)

val get : t -> int -> char
(** [Luv.Buffer.get buffer index] retrieves the character in [buffer] at
    [index].

    Can also be written as [buffer.{index}]. *)

val unsafe_get : t -> int -> char
(** Like {!Luv.Buffer.get}, but does not perform a bounds check. *)

val set : t -> int -> char -> unit
(** [Luv.Buffer.set buffer index value] sets the character in [buffer] at
    [index] to [value].

    Can also be written as [buffer.{index} <- value]. *)

val unsafe_set : t -> int -> char -> unit
(** Like {!Luv.Buffer.set}, but does not perform a bounds check. *)

val sub : t -> offset:int -> length:int -> t
(** [Luv.Buffer.sub buffer ~offset ~length] creates a view into [buffer] that
    starts at the given offset and has the given length.

    No data is copied. *)

val blit : source:t -> destination:t -> unit
(** Copies data from [source] to [destination].

    The amount of data copied is the minimum of the two buffers' size.

    To copy part of a buffer, use {!Luv.Buffer.sub} to create a view, and pass
    the view to [Luv.Buffer.blit]. *)

val fill : t -> char -> unit
(** Fills the given buffer with the given character. *)



(** {1 Conversions} *)

val to_string : t -> string
(** Creates a string with the same contents as the given buffer. *)

val to_bytes : t -> bytes
(** Creates a [bytes] buffer with the same contents as the given buffer. *)

val from_string : string -> t
(** Creates a buffer from a string. *)

val from_bytes : bytes -> t
(** Creates a buffer from [bytes]. *)



(** {1 Converting blits} *)

val blit_to_bytes : t -> bytes -> destination_offset:int -> unit
(** Copies data from a buffer to a [bytes] buffer. *)

val blit_from_bytes : t -> bytes -> source_offset:int -> unit
(** Copies data from a [bytes] buffer to a buffer. *)

val blit_from_string : t -> string -> source_offset:int -> unit
(** Copies data from a string to a buffer. *)



(** {1 Lists of buffers}

    Many Luv functions, such as {!Luv.File.write}, work with lists of buffers
    (i.e., they do scatter-gather I/O). These are helpers for working with
    buffer lists. *)

val total_size : t list -> int
(** Evaluates to the sum of the sizes of the buffers in the list. *)

val drop : t list -> int -> t list
(** [drop buffers count] drops the first [count] bytes from [buffers].

    For example, if [buffers] contains two buffers of size 16, [drop buffers
    18] will evaluate to a list that has lost the reference to the first buffer,
    and contains only a view into the second buffer of size 14. *)
