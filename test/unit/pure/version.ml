let () =
  Printf.printf "Numeric:    %i.%i.%i\n"
    Luv.Version.major Luv.Version.minor Luv.Version.patch;
  Printf.printf "String:     %s\n" (Luv.Version.string ());
  Printf.printf "Hex:        0x%06X\n" Luv.Version.hex;
  Printf.printf "version (): 0x%06X\n" (Luv.Version.version ());
  Printf.printf "is_release: %b\n" Luv.Version.is_release;
  Printf.printf "suffix:     %S\n" Luv.Version.suffix
