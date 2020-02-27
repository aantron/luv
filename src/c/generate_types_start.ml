(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)

let () =
  
  (* Include headers necessary for Windows *)
  if Sys.win32 then
    (* Setting a WINVER to Vista+ is necessary to get types like AI_ADDRCONFIG *)
    (print_endline "#define WINVER 0x0600";
    print_endline "#define _WIN32_WINNT 0x0600";
    print_endline "#include <ws2tcpip.h>");
    
  print_endline "#include <caml/mlvalues.h>";
  print_endline "#include <caml/socketaddr.h>";
  print_endline "#include <uv.h>";
  print_endline "#include \"helpers.h\"";

  Cstubs_structs.write_c
    Format.std_formatter (module Luv_c_type_descriptions.Descriptions)
