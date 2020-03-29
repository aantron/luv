let () =
  Luv.File.open_ Sys.argv.(1) [`RDONLY] begin function
    | Error e ->
      Printf.eprintf "Error opening file: %s\n" (Luv.Error.strerror e)
    | Ok file ->
      let buffer = Luv.Buffer.create 1024 in

      let rec on_read = function
        | Error e ->
          Printf.eprintf "Read error: %s\n" (Luv.Error.strerror e)
        | Ok bytes_read ->
          let bytes_read = Unsigned.Size_t.to_int bytes_read in
          if bytes_read = 0 then
            Luv.File.close file ignore
          else
            Luv.File.write
              Luv.File.stdout
              [Luv.Buffer.sub buffer ~offset:0 ~length:bytes_read]
              on_write

      and on_write = function
        | Error e ->
          Printf.eprintf "Write error: %s\n" (Luv.Error.strerror e)
        | Ok _bytes_written ->
          Luv.File.read file [buffer] on_read

      in

      Luv.File.read file [buffer] on_read
  end;

  ignore (Luv.Loop.run () : bool)
