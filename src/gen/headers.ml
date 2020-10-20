let (//) = Filename.concat

let recursive_search directory =
  let rec traverse full_path subdirectory accumulator =
    Sys.readdir full_path
    |> Array.fold_left (fun accumulator entry ->
      if Sys.is_directory (full_path // entry) then
        traverse (full_path // entry) (subdirectory // entry) accumulator
      else
        (subdirectory // entry)::accumulator)
      accumulator
  in
  traverse directory "" []
  |> List.sort String.compare

let install_stanza relative_path header_files =
  "(install\n (section lib)\n (package luv)\n (files\n" ^
  (header_files
  |> List.map (fun file ->
    "  (" ^ (relative_path // file) ^ " as " ^ file ^ ")")
  |> String.concat "\n") ^
  "))"

let rewrite_dune_file path install_stanza =
  let in_channel = Stdlib.open_in path in
  let rec scan_for_install_stanza lines =
    match Stdlib.input_line in_channel with
    | "(install" -> drop_old_install_stanza (install_stanza::lines)
    | line -> scan_for_install_stanza (line::lines)
  and drop_old_install_stanza lines =
    match Stdlib.input_line in_channel with
    | "" -> append_rest_of_file (""::lines)
    | _ -> drop_old_install_stanza lines
  and append_rest_of_file lines =
    match Stdlib.input_line in_channel with
    | exception End_of_file -> lines
    | line -> append_rest_of_file (line::lines)
  in

  let new_content =
    scan_for_install_stanza []
    |> List.rev
    |> List.map (fun s -> s ^ "\n")
    |> String.concat ""
  in

  Stdlib.close_in in_channel;

  let out_channel = Stdlib.open_out path in
  Stdlib.output_string out_channel new_content;
  Stdlib.close_out out_channel

let () =
  recursive_search "src/c/vendor/libuv/include"
  |> install_stanza "vendor/libuv/include"
  |> rewrite_dune_file "src/c/dune"
