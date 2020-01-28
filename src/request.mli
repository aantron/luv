(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Requests.

    See {{:https://aantron.github.io/luv/basics.html#requests} {i Requests}} in
    the user guide and {{:http://docs.libuv.org/en/v1.x/request.html} [uv_req_t]
    — {i Base request}} in libuv.

    Requests are objects libuv uses to track asynchronous operations, and
    sometimes to communicate their results. For the most part Luv handles
    requests automatically.

    Some request kinds support cancelation, and Luv provides a common function
    {!Luv.Request.cancel} for them.

    Apart from that, this module would be only an internal convenience for the
    implementation of Luv.

    The full list of exposed concrete request types:

    - {!Luv.File.Request.t}
    - {!Luv.DNS.Addr_info.Request.t}
    - {!Luv.DNS.Name_info.Request.t}
    - {!Luv.Thread_pool.Request.t} *)

type 'kind t = 'kind C.Types.Request.t Ctypes.ptr
(** Binds {{:http://docs.libuv.org/en/v1.x/request.html#c.uv_req_t}
    [uv_req_t]}. *)

val cancel :
  [< `File | `Addr_info | `Name_info | `Thread_pool ] t ->
    (unit, Error.t) result
(** Tries to cancel a pending request.

    Binds {{:http://docs.libuv.org/en/v1.x/request.html#c.uv_cancel}
    [uv_cancel]}. *)

(**/**)

(* Internal functions; do not use. *)

val allocate :
  ?reference_count:int -> 'kind C.Types.Request.t Ctypes.typ -> 'kind t
val set_callback : _ t -> (_ -> unit) -> unit
val set_reference : ?index:int -> _ t -> _ -> unit
val release : _ t -> unit
