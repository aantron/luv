let try_file path =
  if Sys.file_exists path then begin
    Sys.rename path "dlluv.so";
    exit 0
  end

let () =
  try_file "vendor/libuv/out/Release/lib.target/libuv.so.1";
  try_file "vendor/libuv/out/Release/libuv.dylib"
