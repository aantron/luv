(* TODO Exclude ptr from Imports, because we will no longer be using it in the
   API. *)
type 'a ptr = 'a Ctypes.ptr
type ('a, 'e) result = ('a, 'e) Result.result = Ok of 'a | Error of 'e
