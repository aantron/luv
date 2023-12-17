(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



type timeval = {
  sec : int64;
  usec : int32;
}

type t = timeval

let gettimeofday () =
  let timeval = Ctypes.make C.Types.Time.Timeval.t in
  C.Functions.Time.gettimeofday (Ctypes.addr timeval)
  |> Error.to_result_lazy begin fun () ->
    {
      sec = Ctypes.getf timeval C.Types.Time.Timeval.sec;
      usec = Ctypes.getf timeval C.Types.Time.Timeval.usec;
    }
  end

let hrtime =
  C.Functions.Time.hrtime

type timespec = {
  sec : int64;
  nsec : int32;
}

let clock_gettime clock =
  let timespec = Ctypes.make C.Types.Time.Timespec.t in
  let clock =
    match clock with
    | `Monotonic -> C.Types.Time.Timespec.monotonic
    | `Real_time -> C.Types.Time.Timespec.real_time
  in
  C.Functions.Time.clock_gettime clock (Ctypes.addr timespec)
  |> Error.to_result_lazy begin fun () ->
    {
      sec = Ctypes.getf timespec C.Types.Time.Timespec.sec;
      nsec = Ctypes.getf timespec C.Types.Time.Timespec.nsec;
    }
  end

let sleep =
  C.Blocking.Time.sleep
