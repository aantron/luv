(* This is given the internal name Request_ to avoid shadowing request.mli in
   for code in this file. *)
(* TODO Rename and/or unscope. *)
(* TODO Simplify. *)
module Request_ =
struct
  type t = [ `File ] Request.t

  let make () =
    Request.allocate C.Types.File.Request.t

  let cleanup request =
    C.Functions.File.req_cleanup (Request.c request)

  let result request =
    Request.c request
    |> C.Functions.File.get_result
    |> PosixTypes.Ssize.to_int
    |> Error.coerce
    |> Error.clamp

  let file request =
    let file_or_error =
      Request.c request
      |> C.Functions.File.get_result
      |> PosixTypes.Ssize.to_int
    in
    Error.to_result file_or_error (Error.coerce file_or_error)

  let byte_count request =
    let count_or_error = C.Functions.File.get_result (Request.c request) in
    if PosixTypes.Ssize.(compare count_or_error zero) >= 0 then
      count_or_error
      |> PosixTypes.Ssize.to_int64
      |> Unsigned.Size_t.of_int64
      |> fun n -> Result.Ok n
    else
      count_or_error
      |> PosixTypes.Ssize.to_int
      |> Error.coerce
      |> fun n -> Result.Error n

  let path request =
    Request.c request
    |> C.Functions.File.get_path
end

module Open_flag =
struct
  include C.Types.File.Open_flag

  type t = int
  let custom i = i
  let (lor) = (lor)
  let list flags = List.fold_left (lor) 0 flags
end

module Mode =
struct
  include C.Types.File.Mode

  type t = int
  let none = 0
  let octal i = i
  let (lor) = (lor)
  let list modes = List.fold_left (lor) 0 modes
end

module Directory_scan =
struct
  type t = {
    request : Request_.t;
    dirent : C.Types.File.Dirent.t;
  }

  type entry_kind = [
    | `Regular_file
    | `Directory
    | `Symlink
    | `FIFO
    | `Socket
    | `Character_device
    | `Block_device
    | `Unknown of int
  ]
  type entry = {
    kind : entry_kind;
    name : string;
  }

  let stop scan =
    Request_.cleanup scan.request

  let next scan =
    let result =
      C.Functions.File.scandir_next
        (Request.c scan.request) (Ctypes.addr scan.dirent)
    in
    if result <> Error.success then begin
      stop scan;
      None
    end
    else begin
      let kind = Ctypes.getf scan.dirent C.Types.File.Dirent.type_ in
      let kind =
        let open C.Types.File.Dirent in
        if kind = file then `Regular_file
        else if kind = dir then `Directory
        else if kind = link then `Symlink
        else if kind = fifo then `FIFO
        else if kind = socket then `Socket
        else if kind = char then `Character_device
        else if kind = block then `Block_device
        else `Unknown kind
      in
      let name = Ctypes.getf scan.dirent C.Types.File.Dirent.name in
      Some {kind; name}
    end

  let start request =
    let dirent = Ctypes.make C.Types.File.Dirent.t in
    {request; dirent}
end

module Stat =
struct
  type timespec = {
    sec : Signed.Long.t;
    nsec : Signed.Long.t;
  }

  type t = {
    dev : Unsigned.UInt64.t;
    mode : Mode.t;
    nlink : Unsigned.UInt64.t;
    uid : Unsigned.UInt64.t;
    gid : Unsigned.UInt64.t;
    rdev : Unsigned.UInt64.t;
    ino : Unsigned.UInt64.t;
    size : Unsigned.UInt64.t;
    blksize : Unsigned.UInt64.t;
    blocks : Unsigned.UInt64.t;
    flags : Unsigned.UInt64.t;
    gen : Unsigned.UInt64.t;
    atim : timespec;
    mtim : timespec;
    ctim : timespec;
    birthtim : timespec;
  }

  let load_timespec c_timespec =
    {
      sec = Ctypes.getf c_timespec C.Types.File.Timespec.tv_sec;
      nsec = Ctypes.getf c_timespec C.Types.File.Timespec.tv_nsec;
    }

  let load request =
    let c_stat =
      Ctypes.(!@) (C.Functions.File.get_statbuf (Request.c request)) in
    let field f = Ctypes.getf c_stat f in
    let module C_stat = C.Types.File.Stat in
    {
      dev = field C_stat.st_dev;
      mode = field C_stat.st_mode |> Unsigned.UInt64.to_int;
      nlink = field C_stat.st_nlink;
      uid = field C_stat.st_uid;
      gid = field C_stat.st_gid;
      rdev = field C_stat.st_rdev;
      ino = field C_stat.st_ino;
      size = field C_stat.st_size;
      blksize = field C_stat.st_blksize;
      blocks = field C_stat.st_blocks;
      flags = field C_stat.st_flags;
      gen = field C_stat.st_gen;
      atim = load_timespec (field C_stat.st_atim);
      mtim = load_timespec (field C_stat.st_mtim);
      ctim = load_timespec (field C_stat.st_ctim);
      birthtim = load_timespec (field C_stat.st_birthtim);
    }
end

module Copy_flag =
struct
  include C.Types.File.Copy_flag

  type t = int
  let none = 0
  let (lor) = (lor)
  let list flags = List.fold_left (lor) 0 flags
end

(* TODO Common definitons of lor, list, etc. *)
module Access_flag =
struct
  include C.Types.File.Access_flag

  type t = int
  let (lor) = (lor)
  let list flags = List.fold_left (lor) 0 flags
end

module Symlink_flag =
struct
  include C.Types.File.Symlink_flag

  type t = int
  let none = 0
  let (lor) = (lor)
  let list flags = List.fold_left (lor) 0 flags
end

type t = C.Types.File.t

module Async =
struct
  let trampoline =
    C.Functions.File.get_trampoline ()

  let open_ ?loop path flags mode callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      Request_.cleanup request;
      callback (Request_.file request)
    end;
    let sync_result =
      C.Functions.File.open_
        (Loop.or_default loop)
        (Request.c request)
        path flags mode
        trampoline
    in
    if sync_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback (Result.Error sync_result)
    end

  let close ?loop file callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      Request_.cleanup request;
      callback (Request_.result request)
    end;
    let sync_result =
      C.Functions.File.close
        (Loop.or_default loop)
        (Request.c request)
        file
        trampoline
    in
    if sync_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback sync_result
    end

  let read_or_write c_function ?loop ?(offset = -1L) file buffers callback =
    let count = List.length buffers in
    let iovecs = C.Functions.Buf.bigstrings_to_iovecs buffers count in
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      C.Functions.Buf.free (Ctypes.to_voidp iovecs);
      ignore (Sys.opaque_identity buffers);
      Request_.cleanup request;
      callback (Request_.byte_count request)
    end;
    let sync_result =
      c_function
        (Loop.or_default loop)
        (Request.c request)
        file iovecs (Unsigned.UInt.of_int count) offset
        trampoline
    in
    if sync_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      C.Functions.Buf.free (Ctypes.to_voidp iovecs);
      callback (Result.Error sync_result)
    end

  let read = read_or_write C.Functions.File.read
  let write = read_or_write C.Functions.File.write

  let unlink ?loop path callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      Request_.cleanup request;
      callback (Request_.result request)
    end;
    let sync_result =
      C.Functions.File.unlink
        (Loop.or_default loop)
        (Request.c request)
        path
        trampoline
    in
    if sync_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback sync_result
    end

  let mkdir ?loop path mode callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      Request_.cleanup request;
      callback (Request_.result request)
    end;
    let sync_result =
      C.Functions.File.mkdir
        (Loop.or_default loop)
        (Request.c request)
        path mode
        trampoline
    in
    if sync_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback sync_result
    end

  let mkdtemp ?loop path callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      let result =
        Error.to_result_lazy
          (fun () -> Request_.path request) (Request_.result request)
      in
      Request_.cleanup request;
      callback result
    end;
    let sync_result =
      C.Functions.File.mkdtemp
        (Loop.or_default loop)
        (Request.c request)
        path
        trampoline
    in
    if sync_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback (Result.Error sync_result)
    end

  (* TODO A bunch of these functions have the same implementation, so maybe factor
    it out? *)
  let rmdir ?loop path callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      Request_.cleanup request;
      callback (Request_.result request)
    end;
    let sync_result =
      C.Functions.File.rmdir
        (Loop.or_default loop)
        (Request.c request)
        path
        trampoline
    in
    if sync_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback sync_result
    end

  let scandir ?loop path callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      let result = Request_.result request in
      if result < Error.success then begin
        Request_.cleanup request;
        callback (Result.Error result)
      end
      else
        callback (Result.Ok (Directory_scan.start request))
    end;
    let sync_result =
      C.Functions.File.scandir
        (Loop.or_default loop)
        (Request.c request)
        path 0
        trampoline
    in
    if sync_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback (Result.Error sync_result)
    end

  let generic_stat c_function ?loop argument callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      let result = Request_.result request in
      if result = Error.success then begin
        let result = Stat.load request in
        Request_.cleanup request;
        callback (Result.Ok result)
      end
      else begin
        Request_.cleanup request;
        callback (Result.Error result)
      end
    end;
    let sync_result =
      c_function
        (Loop.or_default loop)
        (Request.c request)
        argument
        trampoline
    in
    if sync_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback (Result.Error sync_result)
    end

  let stat = generic_stat C.Functions.File.stat
  let lstat = generic_stat C.Functions.File.lstat
  let fstat = generic_stat C.Functions.File.fstat

  let rename ?loop ~from ~to_ callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      Request_.cleanup request;
      callback (Request_.result request)
    end;
    let sync_result =
      C.Functions.File.rename
        (Loop.or_default loop)
        (Request.c request)
        from to_
        trampoline
    in
    if sync_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback sync_result
    end

  let generic_fsync c_function ?loop file callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      Request_.cleanup request;
      callback (Request_.result request)
    end;
    let sync_result =
      c_function
        (Loop.or_default loop)
        (Request.c request)
        file
        trampoline
    in
    if sync_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback sync_result
    end

  let fsync = generic_fsync C.Functions.File.fsync
  let fdatasync = generic_fsync C.Functions.File.fdatasync

  let ftruncate ?loop file length callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      Request_.cleanup request;
      callback (Request_.result request)
    end;
    let sync_result =
      C.Functions.File.ftruncate
        (Loop.or_default loop)
        (Request.c request)
        file length
        trampoline
    in
    if sync_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback sync_result
    end

  let copyfile ?loop ~from ~to_ flags callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      Request_.cleanup request;
      callback (Request_.result request)
    end;
    let sync_result =
      C.Functions.File.copyfile
        (Loop.or_default loop)
        (Request.c request)
        from to_ flags
        trampoline
    in
    if sync_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback sync_result
    end

  let sendfile ?loop ~to_ ~from ~offset length callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      Request_.cleanup request;
      callback (Request_.byte_count request)
    end;
    let sync_result =
      C.Functions.File.sendfile
        (Loop.or_default loop)
        (Request.c request)
        to_ from offset length
        trampoline
    in
    if sync_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback (Result.Error sync_result)
    end

  let access ?loop path mode callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      Request_.cleanup request;
      callback (Request_.result request)
    end;
    let sync_result =
      C.Functions.File.access
        (Loop.or_default loop)
        (Request.c request)
        path mode
        trampoline
    in
    if sync_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback sync_result
    end

  let generic_chmod c_function ?loop argument mode callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      Request_.cleanup request;
      callback (Request_.result request)
    end;
    (* TODO Rename all sync_result to immediate_result. *)
    let sync_result =
      c_function
        (Loop.or_default loop)
        (Request.c request)
        argument mode
        trampoline
    in
    if sync_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback sync_result
    end

  let chmod = generic_chmod C.Functions.File.chmod
  let fchmod = generic_chmod C.Functions.File.fchmod

  let generic_utime c_function ?loop argument ~atime ~mtime callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      Request_.cleanup request;
      callback (Request_.result request)
    end;
    let immediate_result =
      c_function
        (Loop.or_default loop)
        (Request.c request)
        argument atime mtime
        trampoline
    in
    if immediate_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback immediate_result
    end

  let utime = generic_utime C.Functions.File.utime
  let futime = generic_utime C.Functions.File.futime

  let link ?loop ~target ~link callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      Request_.cleanup request;
      callback (Request_.result request)
    end;
    let immediate_result =
      C.Functions.File.link
        (Loop.or_default loop)
        (Request.c request)
        target link
        trampoline
    in
    if immediate_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback immediate_result
    end

  let symlink ?loop ~target ~link flags callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      Request_.cleanup request;
      callback (Request_.result request)
    end;
    let immediate_result =
      C.Functions.File.symlink
        (Loop.or_default loop)
        (Request.c request)
        target link flags
        trampoline
    in
    if immediate_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback immediate_result
    end

  let generic_readpath c_function ?loop path callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      let result =
        Error.to_result_lazy
          (fun () -> C.Functions.File.get_ptr (Request.c request))
          (Request_.result request)
      in
      Request_.cleanup request;
      callback result
    end;
    let immediate_result =
      c_function
        (Loop.or_default loop)
        (Request.c request)
        path
        trampoline
    in
    if immediate_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback (Result.Error immediate_result)
    end

  let readlink = generic_readpath C.Functions.File.readlink
  let realpath = generic_readpath C.Functions.File.realpath

  let generic_chown c_function ?loop argument uid gid callback =
    let request = Request_.make () in
    Request.set_callback_1 request begin fun request ->
      Request_.cleanup request;
      callback (Request_.result request)
    end;
    let immediate_result =
      c_function
        (Loop.or_default loop)
        (Request.c request)
        argument uid gid
        trampoline
    in
    if immediate_result = Error.success then
      ()
    else begin
      Request.clear_callback request;
      Request_.cleanup request;
      callback immediate_result
    end

  let chown = generic_chown C.Functions.File.chown
  let fchown = generic_chown C.Functions.File.fchown
  (* let lchown = generic_chown C.Functions.File.lchown *)
end

module Sync =
struct
  let null_callback =
    C.Functions.File.get_null_callback ()

  let open_ path flags mode =
    let request = Request_.make () in
    let result =
      C.Functions.File.open_
        (Loop.default ())
        (Request.c request)
        path flags mode
        null_callback
    in
    Request_.cleanup request;
    if result < Error.success then
      Result.Error result
    else
      Request_.file request

  let close file =
    let request = Request_.make () in
    let result =
      C.Functions.File.close
        (Loop.default ())
        (Request.c request)
        file
        null_callback
    in
    Request_.cleanup request;
    result

  let read_or_write c_function ?(offset = -1L) file buffers =
    let count = List.length buffers in
    let iovecs = C.Functions.Buf.bigstrings_to_iovecs buffers count in
    let request = Request_.make () in
    let result =
      c_function
        (Loop.default ())
        (Request.c request)
        file iovecs (Unsigned.UInt.of_int count) offset
        null_callback
    in
    Request_.cleanup request;
    if result < Error.success then
      Result.Error result
    else
      Request_.byte_count request

  let read = read_or_write C.Functions.File.read
  let write = read_or_write C.Functions.File.write

  let unlink path =
    let request = Request_.make () in
    let result =
      C.Functions.File.unlink
        (Loop.default ())
        (Request.c request)
        path
        null_callback
    in
    Request_.cleanup request;
    result

  let mkdir path mode =
    let request = Request_.make () in
    let result =
      C.Functions.File.mkdir
        (Loop.default ())
        (Request.c request)
        path mode
        null_callback
    in
    Request_.cleanup request;
    result

  let mkdtemp path =
    let request = Request_.make () in
    let result =
      C.Functions.File.mkdtemp
        (Loop.default ())
        (Request.c request)
        path
        null_callback
    in
    if result <> Error.success then begin
      Request_.cleanup request;
      Result.Error result
    end
    else begin
      let path = Request_.path request in
      Request_.cleanup request;
      Result.Ok path
    end

  let rmdir path =
    let request = Request_.make () in
    let result =
      C.Functions.File.rmdir
        (Loop.default ())
        (Request.c request)
        path
        null_callback
    in
    Request_.cleanup request;
    result

  let scandir path =
    let request = Request_.make () in
    let result =
      C.Functions.File.scandir
        (Loop.default ())
        (Request.c request)
        path 0
        null_callback
    in
    if result < Error.success then begin
      Request_.cleanup request;
      Result.Error result
    end
    else
      Result.Ok (Directory_scan.start request)

  let generic_stat c_function argument =
    let request = Request_.make () in
    let result =
      c_function
        (Loop.default ())
        (Request.c request)
        argument
        null_callback
    in
    if result <> Error.success then begin
      Request_.cleanup request;
      Result.Error result
    end
    else begin
      let result = Stat.load request in
      Request_.cleanup request;
      Result.Ok result
    end

  let stat = generic_stat C.Functions.File.stat
  let lstat = generic_stat C.Functions.File.lstat
  let fstat = generic_stat C.Functions.File.fstat

  let rename ~from ~to_ =
    let request = Request_.make () in
    let result =
      C.Functions.File.rename
        (Loop.default ())
        (Request.c request)
        from to_
        null_callback
    in
    Request_.cleanup request;
    result

  let generic_fsync c_function file =
    let request = Request_.make () in
    let result =
      c_function
        (Loop.default ())
        (Request.c request)
        file
        null_callback
    in
    Request_.cleanup request;
    result

  let fsync = generic_fsync C.Functions.File.fsync
  let fdatasync = generic_fsync C.Functions.File.fdatasync

  let ftruncate file length =
    let request = Request_.make () in
    let result =
      C.Functions.File.ftruncate
        (Loop.default ())
        (Request.c request)
        file length
        null_callback
    in
    Request_.cleanup request;
    result

  let copyfile ~from ~to_ flags =
    let request = Request_.make () in
    let result =
      C.Functions.File.copyfile
        (Loop.default ())
        (Request.c request)
        from to_ flags
        null_callback
    in
    Request_.cleanup request;
    result

  let sendfile ~to_ ~from ~offset length =
    let request = Request_.make () in
    let result =
      C.Functions.File.sendfile
        (Loop.default ())
        (Request.c request)
        to_ from offset length
        null_callback
    in
    Request_.cleanup request;
    if result < Error.success then
      Result.Error result
    else
      Request_.byte_count request

  let access path mode =
    let request = Request_.make () in
    let result =
      C.Functions.File.access
        (Loop.default ())
        (Request.c request)
        path mode
        null_callback
    in
    Request_.cleanup request;
    result

  let generic_chmod c_function argument mode =
    let request = Request_.make () in
    let result =
      c_function
        (Loop.default ())
        (Request.c request)
        argument mode
        null_callback
    in
    Request_.cleanup request;
    result

  let chmod = generic_chmod C.Functions.File.chmod
  let fchmod = generic_chmod C.Functions.File.fchmod

  let generic_utime c_function argument ~atime ~mtime =
    let request = Request_.make () in
    let result =
      c_function
        (Loop.default ())
        (Request.c request)
        argument atime mtime
        null_callback
    in
    Request_.cleanup request;
    result

  let utime = generic_utime C.Functions.File.utime
  let futime = generic_utime C.Functions.File.futime

  let link ~target ~link =
    let request = Request_.make () in
    let result =
      C.Functions.File.link
        (Loop.default ())
        (Request.c request)
        target link
        null_callback
    in
    Request_.cleanup request;
    result

  let symlink ~target ~link flags =
    let request = Request_.make () in
    let result =
      C.Functions.File.symlink
        (Loop.default ())
        (Request.c request)
        target link flags
        null_callback
    in
    Request_.cleanup request;
    result

  let generic_readpath c_function path =
    let request = Request_.make () in
    let result =
      c_function
        (Loop.default ())
        (Request.c request)
        path
        null_callback
    in
    if result <> Error.success then begin
      Request_.cleanup request;
      Result.Error result
    end
    else begin
      let path = C.Functions.File.get_path (Request.c request) in
      Request_.cleanup request;
      Result.Ok path
    end

  let readlink = generic_readpath C.Functions.File.readlink
  let realpath = generic_readpath C.Functions.File.realpath

  let generic_chown c_function argument uid gid =
    let request = Request_.make () in
    let result =
      c_function
        (Loop.default ())
        (Request.c request)
        argument uid gid
        null_callback
    in
    Request_.cleanup request;
    result

  let chown = generic_chown C.Functions.File.chown
  let fchown = generic_chown C.Functions.File.fchown
  (* let lchown = generic_chown C.Functions.File.lchown *)
end

module Request = Request_
