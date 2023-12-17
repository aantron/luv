(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type user = {
  username : string;
  uid : Unsigned.ulong;
  gid : Unsigned.ulong;
  shell : string option;
  homedir : string;
}

type t = user

let get_passwd ?uid () =
  let c_passwd = Ctypes.make C.Types.Passwd.t in
  let pointer = Ctypes.addr c_passwd in
  begin match uid with
  | None -> C.Functions.Passwd.get_passwd pointer
  | Some uid -> C.Functions.Passwd.get_passwd2 pointer uid
  end
  |> Error.to_result_f begin fun () ->
    let module PW = C.Types.Passwd in
    let passwd = {
      username = Ctypes.getf c_passwd PW.username;
      uid = Ctypes.getf c_passwd PW.uid;
      gid = Ctypes.getf c_passwd PW.gid;
      shell = Ctypes.getf c_passwd PW.shell;
      homedir = Ctypes.getf c_passwd PW.homedir;
    }
    in
    C.Functions.Passwd.free_passwd pointer;
    passwd
  end

type group = {
  groupname : string;
  gid : Unsigned.ulong;
  members : string list;
}

let strlen c_string =
  let rec loop i =
    if Ctypes.(!@ (c_string +@ i)) = '\x00' then
      i
    else
      loop (i + 1)
  in
  loop 0

let string_list_from_c c_strings =
  let rec loop i acc =
    let c_string = Ctypes.(!@ (c_strings +@ i)) in
    if Ctypes.is_null c_string then
      List.rev acc
    else
      let length = strlen c_string in
      let s = Ctypes.string_from_ptr c_string ~length in
      loop (i + 1) (s::acc)
  in
  loop 0 []

let get_group gid =
  let c_group = Ctypes.make C.Types.Passwd.group in
  C.Functions.Passwd.get_group (Ctypes.addr c_group) gid
  |> Error.to_result_f begin fun () ->
    let module G = C.Types.Passwd in
    let group = {
      groupname = Ctypes.getf c_group G.groupname;
      gid = Ctypes.getf c_group G.group_gid;
      members = Ctypes.getf c_group G.members |> string_list_from_c;
    }
    in
    C.Functions.Passwd.free_group (Ctypes.addr c_group);
    group
  end
