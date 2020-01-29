let () =
  Luv.Network.interface_addresses ()
  |> Stdlib.Result.get_ok
  |> List.iter begin fun interface ->
    let open Luv.Network.Interface_address in

    print_endline interface.name;

    if interface.is_internal then
      print_endline " Internal";

    Printf.printf " Physical: %02x:%02x:%02x:%02x:%02x:%02x\n"
      (Char.code interface.physical.[0])
      (Char.code interface.physical.[1])
      (Char.code interface.physical.[2])
      (Char.code interface.physical.[3])
      (Char.code interface.physical.[4])
      (Char.code interface.physical.[5]);

    Printf.printf " Address:  %s\n"
      (Option.get (Luv.Sockaddr.to_string interface.address));

    Printf.printf " Netmask:  %s\n"
      (Option.get (Luv.Sockaddr.to_string interface.netmask))
  end
