(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type t = {
  tv_sec : int64;
  tv_usec : int32;
}

let gettimeofday () =
  let timeval = Ctypes.make C.Types.Time.Timeval.t in
  C.Functions.Time.gettimeofday (Ctypes.addr timeval)
  |> Error.to_result_lazy begin fun () ->
    {
      tv_sec = Ctypes.getf timeval C.Types.Time.Timeval.sec;
      tv_usec = Ctypes.getf timeval C.Types.Time.Timeval.usec;
    }
  end

let hrtime =
  C.Functions.Time.hrtime

let sleep =
  C.Functions.Time.sleep