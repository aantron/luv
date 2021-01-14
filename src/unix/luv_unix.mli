(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Error = Luv.Error

module Os_fd :
sig
  module Fd :
  sig
    include module type of Luv.Os_fd.Fd

    val from_unix : Unix.file_descr -> (t, Error.t) result
    (** Attempts to convert from a
        {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Unix.html#TYPEfile_descr}
        [Unix.file_descr]} to a libuv [uv_os_fd_t]. Fails on Windows if the
        descriptor is a [SOCKET] rather than a [HANDLE]. *)

    val to_unix : t -> Unix.file_descr
    (** Converts a [uv_os_fd_t] to a
        {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Unix.html#TYPEfile_descr}
        [Unix.file_descr]}. *)
  end

  module Socket :
  sig
    include module type of Luv.Os_fd.Socket

    val from_unix : Unix.file_descr -> (t, Error.t) result
    (** Attempts to convert from a
        {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Unix.html#TYPEfile_descr}
        [Unix.file_descr]} to a libuv [uv_os_sock_t]. Fails on Windows if the
        descriptor is a [HANDLE] rather than a [SOCKET]. *)

    val to_unix : t -> Unix.file_descr
    (** Converts a [uv_os_sock_t] to a
        {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Unix.html#TYPEfile_descr}
        [Unix.file_descr]}. *)
  end
end
