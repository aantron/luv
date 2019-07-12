open Test_helpers

let tests = [
  "system name", [
    "uname", `Quick, begin fun () ->
      let uname = Luv.System_name.uname () |> check_success_result "uname" in
      if uname.sysname <> "Linux" && uname.sysname <> "Darwin" then
        Alcotest.failf "sysname: got %s" uname.sysname;
      Alcotest.(check string) "machine" "x86_64" uname.machine;
    end;
  ];

  "time", [
    "gettimeofday", `Quick, begin fun () ->
      let timeval =
        Luv.Time.gettimeofday () |> check_success_result "gettimeofday" in
      let uv_time =
        let open Luv.Time in
        (Int64.to_float timeval.tv_sec) +.
          (Int32.to_float timeval.tv_usec) *. 1e-6
      in
      let ocaml_time = Unix.gettimeofday () in

      let delta = abs_float (uv_time -. ocaml_time) in
      if delta > 1. then
        Alcotest.failf "times: %f %f" uv_time ocaml_time
    end;
  ];
]
