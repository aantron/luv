(* TODO The concurrency policy probably needs to be "unlocked". *)

module C =
struct
  module Types = Types
  module Functions = Libuv_functions.Make (FFI_generated_functions)
end
