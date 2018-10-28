module Types = Luv_c_types
module Functions =
  Luv_c_function_descriptions.Descriptions
    (Luv_c_generated_functions.Non_blocking)
module Blocking =
  Luv_c_function_descriptions.Blocking
    (Luv_c_generated_functions.Blocking)
