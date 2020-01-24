(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let resident_set_memory () =
  let size = Ctypes.(allocate size_t Unsigned.Size_t.zero) in
  C.Functions.Resource.resident_set_memory size
  |> Error.to_result (Ctypes.(!@) size)

let uptime () =
  let time = Ctypes.(allocate double) 0. in
  C.Functions.Resource.uptime time
  |> Error.to_result (Ctypes.(!@) time)

let loadavg () =
  let averages = Ctypes.(allocate_n double) ~count:3 in
  C.Functions.Resource.loadavg averages;
  let open Ctypes in
  (!@ averages, !@ (averages +@ 1), !@ (averages +@ 2))

let free_memory =
  C.Functions.Resource.free_memory

let total_memory =
  C.Functions.Resource.total_memory

let constrained_memory () =
  let result = C.Functions.Resource.constrained_memory () in
  if result = Unsigned.UInt64.zero then
    None
  else
    Some result

let getpriority pid =
  let priority = Ctypes.(allocate int) 0 in
  C.Functions.Resource.getpriority pid priority
  |> Error.to_result (Ctypes.(!@) priority)

let setpriority pid priority =
  C.Functions.Resource.setpriority pid priority
  |> Error.to_result ()

type timeval = {
  sec : Signed.Long.t;
  usec : Signed.Long.t;
}

type rusage = {
  utime : timeval;
  stime : timeval;
  maxrss : Unsigned.uint64;
  ixrss : Unsigned.uint64;
  idrss : Unsigned.uint64;
  isrss : Unsigned.uint64;
  minflt : Unsigned.uint64;
  majflt : Unsigned.uint64;
  nswap : Unsigned.uint64;
  inblock : Unsigned.uint64;
  oublock : Unsigned.uint64;
  msgsnd : Unsigned.uint64;
  msgrcv : Unsigned.uint64;
  nsignals : Unsigned.uint64;
  nvcsw : Unsigned.uint64;
  nivcsw : Unsigned.uint64;
}

let load_timeval c_timeval =
  {
    sec = Ctypes.getf c_timeval C.Types.Resource.Timeval.sec;
    usec = Ctypes.getf c_timeval C.Types.Resource.Timeval.usec;
  }

let getrusage () =
  let c_rusage = Ctypes.make C.Types.Resource.Rusage.t in
  C.Functions.Resource.getrusage (Ctypes.addr c_rusage)
  |> Error.to_result_lazy begin fun () ->
    let module RU = C.Types.Resource.Rusage in
    let field name = Ctypes.getf c_rusage name in
    {
      utime = field RU.utime |> load_timeval;
      stime = field RU.stime |> load_timeval;
      maxrss = field RU.maxrss;
      ixrss = field RU.ixrss;
      idrss = field RU.idrss;
      isrss = field RU.isrss;
      minflt = field RU.minflt;
      majflt = field RU.majflt;
      nswap = field RU.nswap;
      inblock = field RU.inblock;
      oublock = field RU.oublock;
      msgsnd = field RU.msgsnd;
      msgrcv = field RU.msgrcv;
      nsignals = field RU.nsignals;
      nvcsw = field RU.nvcsw;
      nivcsw = field RU.nivcsw;
    }
  end
