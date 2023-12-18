(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



let available_parallelism =
  C.Functions.CPU_info.available_parallelism

module CPU_info =
struct
  type times = {
    user : Unsigned.uint64;
    nice : Unsigned.uint64;
    sys : Unsigned.uint64;
    idle : Unsigned.uint64;
    irq : Unsigned.uint64;
  }

  type t = {
    model : string;
    speed : int;
    times : times;
  }
end

let cpu_info () =
  let null = Ctypes.(from_voidp C.Types.CPU_info.t null) in
  let info = Ctypes.(allocate (ptr C.Types.CPU_info.t)) null in
  let count = Ctypes.(allocate int) 0 in

  C.Functions.CPU_info.cpu_info info count
  |> Error.to_result_f @@ fun () ->
  let info = Ctypes.(!@) info in
  let count = Ctypes.(!@) count in

  let rec convert_info index =
    if index >= count then
      []
    else begin
      let module CI = C.Types.CPU_info in
      let c_cpu_info = Ctypes.(!@ (info +@ index)) in
      let c_times = Ctypes.getf c_cpu_info CI.times in
      let cpu_info = CPU_info.{
        model = Ctypes.getf c_cpu_info CI.model;
        speed = Ctypes.getf c_cpu_info CI.speed;
        times = {
          user = Ctypes.getf c_times CI.Times.user;
          nice = Ctypes.getf c_times CI.Times.nice;
          sys = Ctypes.getf c_times CI.Times.sys;
          idle = Ctypes.getf c_times CI.Times.idle;
          irq = Ctypes.getf c_times CI.Times.irq;
        };
      }
      in
      cpu_info::(convert_info (index + 1))
    end
  in
  let cpu_times = convert_info 0 in
  C.Functions.CPU_info.free_cpu_info info count;
  cpu_times

let cpumask_size () =
  let size = C.Functions.Thread.cpumask_size () in
  Error.to_result size size

module Uname =
struct
  type t = {
    sysname : string;
    release : string;
    version : string;
    machine : string;
  }

  let field_length = 256

  let extract_field buffer index =
    let offset = index * field_length in
    let length =
      match Bytes.index_from buffer offset '\000' with
      | n when n < offset + field_length -> n - offset
      | _ -> field_length
      | exception Not_found -> field_length
    in
    Bytes.sub_string buffer offset length
  end

  let uname () =
    let buffer = Bytes.create (Uname.field_length * 4) in
    C.Functions.Uname.uname (Ctypes.ocaml_bytes_start buffer)
    |> Error.to_result_f @@ fun () ->
    Uname.{
      sysname = extract_field buffer 0;
      release = extract_field buffer 1;
      version = extract_field buffer 2;
      machine = extract_field buffer 3;
    }
