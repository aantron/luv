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
]
