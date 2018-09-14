let pp_error_code formatter error_code =
  if error_code = Luv.Error.Code.success then
    Format.pp_print_string formatter "success (0)"
  else
    Format.fprintf
      formatter
      "%s (%s, %i)"
      (Luv.Error.strerror error_code)
      (Luv.Error.err_name error_code)
      (error_code :> int)

let error_code_testable =
  Alcotest.of_pp pp_error_code

let fail_with_error_code name error_code =
  Fmt.to_to_string pp_error_code error_code
  |> Alcotest.failf "%s failed with %s" name

let check_success name error_code =
  if error_code <> Luv.Error.Code.success then
    fail_with_error_code name error_code

let check_error_code name expected error_code =
  Alcotest.check error_code_testable name expected error_code

let check_success_result name result =
  match result with
  | Result.Ok value -> value
  | Result.Error code -> fail_with_error_code name code

let pointer_testable =
  let format formatter pointer =
    if Ctypes.is_null pointer then
      Format.pp_print_string formatter "null"
    else
      Format.fprintf formatter "%nX" (Ctypes.raw_address_of_ptr pointer)
  in

  let equal pointer pointer' =
    Ctypes.raw_address_of_ptr pointer = Ctypes.raw_address_of_ptr pointer'
  in

  Alcotest.testable format equal

let check_not_null name pointer =
  Alcotest.check
    (Alcotest.neg pointer_testable) name Ctypes.null (Ctypes.to_voidp pointer)

let check_pointer name expected actual =
  Alcotest.check
    pointer_testable name (Ctypes.to_voidp expected) (Ctypes.to_voidp actual)

(* let pp_handle_type formatter handle_type =
  Format.fprintf
    formatter "%s (%i)" (Luv.Handle.type_name handle_type) (handle_type :> int)

let handle_type_testable =
  Alcotest.of_pp pp_handle_type

let check_handle_type expected actual =
  Alcotest.(check handle_type_testable) "handle type" expected actual *)

let count_allocated_words () =
  Gc.full_major ();
  Gc.((stat ()).live_words)

let count_allocated_words_during repetitions f =
  let initial = count_allocated_words () in
  for i = 1 to repetitions do
    f i
  done;
  Pervasives.max 0 (count_allocated_words () - initial)

let callback_index = ref 0
let accumulator = ref 0

let make_callback () =
  let index = !callback_index in
  callback_index := !callback_index + 1;

  fun _ ->
    accumulator := !accumulator + index

let no_memory_leak ?(base_repetitions = 100) f =
  let allocated_during_first_run =
    count_allocated_words_during base_repetitions f
    |> float_of_int
  in
  let allocated_during_second_run =
    count_allocated_words_during (base_repetitions * 3) f
    |> float_of_int
  in

  if allocated_during_second_run /. allocated_during_first_run > 1.1 then
    Alcotest.failf
      "memory leak: %.0f, then %.0f words allocated"
      allocated_during_first_run
      allocated_during_second_run

let default_loop =
  Luv.Loop.default ()

let run () =
  Luv.Loop.run default_loop Luv.Loop.Run_mode.default
  |> Alcotest.(check bool) "run" false

let port = ref 5000
let port () =
  port := !port + 1;
  !port
