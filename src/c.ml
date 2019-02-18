(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Types = Luv_c_types
module Functions =
  Luv_c_function_descriptions.Descriptions
    (Luv_c_generated_functions.Non_blocking)
module Blocking =
  Luv_c_function_descriptions.Blocking
    (Luv_c_generated_functions.Blocking)
