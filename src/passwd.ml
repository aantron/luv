(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = {
  username : string;
  uid : Unsigned.ulong;
  gid : Unsigned.ulong;
  shell : string option;
  homedir : string;
}

let get_passwd () =
  let c_passwd = Ctypes.make C.Types.Passwd.t in
  C.Functions.Passwd.get_passwd (Ctypes.addr c_passwd)
  |> Error.to_result_lazy begin fun () ->
    let module PW = C.Types.Passwd in
    let passwd = {
      username = Ctypes.getf c_passwd PW.username;
      uid = Ctypes.getf c_passwd PW.uid;
      gid = Ctypes.getf c_passwd PW.gid;
      shell = Ctypes.getf c_passwd PW.shell;
      homedir = Ctypes.getf c_passwd PW.homedir;
    }
    in
    C.Functions.Passwd.free (Ctypes.addr c_passwd);
    passwd
  end
