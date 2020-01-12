(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



include Promisify_signatures

module With_promise_type (Promise : PROMISE) =
struct
  let from_cps f =
    let p, resolve = Promise.make () in
    f resolve;
    p

  module Timer =
  struct
    let delay ?loop ?call_update_time time =
      let p, resolve = Promise.make () in
      begin match Timer.init ?loop () with
      | Result.Error _ as error -> resolve error
      | Result.Ok timer ->
        let immediate_result =
          Timer.start ?call_update_time timer time begin fun () ->
            Handle.close timer ignore;
            resolve (Result.Ok ())
          end
        in
        if immediate_result <> (Result.Ok ()) then
          resolve immediate_result
      end;
      p
  end

  module Stream =
  struct
    let shutdown stream =
      from_cps (Stream.shutdown stream)

    let read ?allocate stream =
      let p, resolve = Promise.make () in
      Stream.read_start ?allocate stream begin fun result ->
        ignore (Stream.read_stop stream);
        resolve result
      end;
      p

    let write ?send_handle stream buffers =
      let p, resolve = Promise.make () in
      Stream.write ?send_handle stream buffers (fun error count ->
        resolve (error, count));
      p
  end

  module TCP =
  struct
    let connect tcp address =
      from_cps (TCP.connect tcp address)
  end

  module File =
  struct
    let open_ ?loop ?request ?mode path flags =
      from_cps (File.Async.open_ ?loop ?request ?mode path flags)

    let close ?loop ?request file =
      from_cps (File.Async.close ?loop ?request file)

    let read ?loop ?request ?offset file buffers =
      from_cps (File.Async.read ?loop ?request ?offset file buffers)
  end

  module DNS =
  struct
    module Addr_info = DNS.Addr_info
    module Name_info = DNS.Name_info

    let getaddrinfo
        ?loop ?request ?family ?socktype ?protocol ?flags ?node ?service () =

      from_cps
        (DNS.getaddrinfo
          ?loop ?request ?family ?socktype ?protocol ?flags ?node ?service ())

    let getnameinfo ?loop ?request ?flags address =
      from_cps (DNS.getnameinfo ?loop ?request ?flags address)
  end
end
