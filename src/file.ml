(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(* This is given the internal name Request_ to avoid shadowing request.mli in
   for code in this file. *)
module Request_ =
struct
  type t = [ `File ] Request.t

  let make () =
    Request.allocate C.Types.File.Request.t

  let or_make maybe_request =
    match maybe_request with
    | Some request -> request
    | None -> make ()

  let cleanup =
    C.Blocking.File.req_cleanup

  let int_result request =
    request
    |> C.Blocking.File.get_result
    |> PosixTypes.Ssize.to_int

  let result request =
    int_result request
    |> Error.clamp

  let file request =
    let file_or_error = int_result request in
    Error.to_result file_or_error file_or_error

  let byte_count request =
    let count_or_error = C.Blocking.File.get_result request in
    if PosixTypes.Ssize.(compare count_or_error zero) >= 0 then
      count_or_error
      |> PosixTypes.Ssize.to_int64
      |> Unsigned.Size_t.of_int64
      |> fun n -> Result.Ok n
    else
      count_or_error
      |> PosixTypes.Ssize.to_int
      |> fun n -> Error.result_from_c n

  let path =
    C.Blocking.File.get_path
end

module Open_flag =
struct
  type t = [
    | `RDONLY
    | `WRONLY
    | `RDWR

    | `CREAT
    | `EXCL
    | `EXLOCK
    | `NOCTTY
    | `NOFOLLOW
    | `TEMPORARY
    | `TRUNC

    | `APPEND
    | `DIRECT
    | `DSYNC
    | `FILEMAP
    | `NOATIME
    | `NONBLOCK
    | `RANDOM
    | `SEQUENTIAL
    | `SHORT_LIVED
    | `SYMLINK
    | `SYNC
  ]

  let to_c = let open C.Types.File.Open_flag in function
    | `RDONLY -> rdonly
    | `WRONLY -> wronly
    | `RDWR -> rdwr

    | `CREAT -> creat
    | `EXCL -> excl
    | `EXLOCK -> exlock
    | `NOCTTY -> noctty
    | `NOFOLLOW -> nofollow
    | `TEMPORARY -> temporary
    | `TRUNC -> trunc

    | `APPEND -> append
    | `DIRECT -> direct
    | `DSYNC -> dsync
    | `FILEMAP -> filemap
    | `NOATIME -> noatime
    | `NONBLOCK -> nonblock
    | `RANDOM -> random
    | `SEQUENTIAL -> sequential
    | `SHORT_LIVED -> short_lived
    | `SYMLINK -> symlink
    | `SYNC -> sync
end

module Mode =
struct
  type t = [
    | `IRWXU
    | `IRUSR
    | `IWUSR
    | `IXUSR

    | `IRWXG
    | `IRGRP
    | `IWGRP
    | `IXGRP

    | `IRWXO
    | `IROTH
    | `IWOTH
    | `IXOTH

(* TODO: Not supported on Windows
    | `ISUID
    | `ISGID
    | `ISVTX
*)

    | `NUMERIC of int
  ]

  let to_c = let open C.Types.File.Mode in function
    | `IRWXU -> irwxu
    | `IRUSR -> irusr
    | `IWUSR -> iwusr
    | `IXUSR -> ixusr

    | `IRWXG -> irwxg
    | `IRGRP -> irgrp
    | `IWGRP -> iwgrp
    | `IXGRP -> ixgrp

    | `IRWXO -> irwxo
    | `IROTH -> iroth
    | `IWOTH -> iwoth
    | `IXOTH -> ixoth

    (*| `ISUID -> isuid
    | `ISGID -> isgid
    | `ISVTX -> isvtx*)

    | `NUMERIC i -> i

  let file_default = [`NUMERIC 0o644]
  let directory_default = [`NUMERIC 0o755]

  type numeric = int

  let list_to_c =
    Helpers.Bit_field.list_to_c to_c

  let test =
    Helpers.Bit_field.test to_c
end

module Dirent =
struct
  module Kind = C.Types.File.Dirent.Kind

  type t = {
    kind : Kind.t;
    name : string;
  }

  let from_c c_dirent =
    {
      kind = Ctypes.getf c_dirent C.Types.File.Dirent.type_;
      name = Ctypes.getf c_dirent C.Types.File.Dirent.name
    }
end

module Dir =
struct
  type t = C.Types.File.Dir.t Ctypes.ptr

  let from_request request =
    C.Blocking.File.get_ptr request
    |> Ctypes.from_voidp C.Types.File.Dir.t
end

module Directory_scan =
struct
  type t = {
    request : Request_.t;
    dirent : C.Types.File.Dirent.t;
  }

  let stop scan =
    Request_.cleanup scan.request

  let next scan =
    let result =
      C.Blocking.File.scandir_next scan.request (Ctypes.addr scan.dirent) in
    if result < 0 then begin
      stop scan;
      None
    end
    else
      Some (Dirent.from_c scan.dirent)

  let start request =
    let dirent = Ctypes.make C.Types.File.Dirent.t in
    {request; dirent}
end

let scandir_next =
  Directory_scan.next

let scandir_end =
  Directory_scan.stop

module Stat =
struct
  type timespec = {
    sec : Signed.Long.t;
    nsec : Signed.Long.t;
  }

  type t = {
    dev : Unsigned.UInt64.t;
    mode : Mode.numeric;
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

  let load stat =
    let field f = Ctypes.getf stat f in
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

  let from_request request =
    load (Ctypes.(!@) (C.Blocking.File.get_statbuf request))
end

module Statfs =
struct
  type t = {
    type_ : Unsigned.UInt64.t;
    bsize : Unsigned.UInt64.t;
    blocks : Unsigned.UInt64.t;
    bfree : Unsigned.UInt64.t;
    bavail : Unsigned.UInt64.t;
    files : Unsigned.UInt64.t;
    ffree : Unsigned.UInt64.t;
    f_spare :
      Unsigned.UInt64.t
      * Unsigned.UInt64.t
      * Unsigned.UInt64.t
      * Unsigned.UInt64.t;
  }

  let from_request request =
    let module C_statfs = C.Types.File.Statfs in
    let c_statfs =
      Ctypes.(!@ (from_voidp C_statfs.t (C.Blocking.File.get_ptr request))) in
    let field f = Ctypes.getf c_statfs f in
    {
      type_ = field C_statfs.f_type;
      bsize = field C_statfs.f_bsize;
      blocks = field C_statfs.f_blocks;
      bfree = field C_statfs.f_bfree;
      bavail = field C_statfs.f_bavail;
      files = field C_statfs.f_files;
      ffree = field C_statfs.f_ffree;
      f_spare =
        let array = field C_statfs.f_spare in
        Ctypes.CArray.get array 0,
        Ctypes.CArray.get array 1,
        Ctypes.CArray.get array 2,
        Ctypes.CArray.get array 3
    }
end

module Access_flag =
struct
  type t = [
    | `F_OK
    | `R_OK
    | `W_OK
    | `X_OK
  ]

  let to_c = let open C.Types.File.Access_flag in function
    | `F_OK -> f
    | `R_OK -> r
    | `W_OK -> w
    | `X_OK -> x
end

module Returns =
struct
  type 'a t = {
    from_request : Request_.t -> 'a;
    immediate_error : int -> 'a;
    clean_up_request_on_success : bool;
  }

  let returns_error = {
    from_request = (fun request ->
      Request_.result request |> Error.to_result ());
    immediate_error = Error.to_result ();
    clean_up_request_on_success = true;
  }

  let returns_file = {
    from_request = Request_.file;
    immediate_error = Error.result_from_c;
    clean_up_request_on_success = true;
  }

  let returns_byte_count = {
    from_request = Request_.byte_count;
    immediate_error = Error.result_from_c;
    clean_up_request_on_success = true;
  }

  let returns_path = {
    from_request = (fun request ->
      Error.to_result_lazy
        (fun () -> Request_.path request) (Request_.result request));
    immediate_error = Error.result_from_c;
    clean_up_request_on_success = true;
  }

  let returns_path_and_file = {
    from_request = (fun request ->
      Error.to_result_lazy
        (fun () -> Request_.path request, (Request_.int_result request))
        (Request_.result request));
    immediate_error = Error.result_from_c;
    clean_up_request_on_success = true;
  }

  let returns_directory_handle = {
    from_request = (fun request ->
      Error.to_result_lazy
        (fun () -> Dir.from_request request)
        (Request_.result request));
    immediate_error = Error.result_from_c;
    clean_up_request_on_success = true;
  }

  let returns_directory_entries = {
    from_request = (fun request ->
      Error.to_result_lazy
        (fun () ->
          let dirents =
            Dir.from_request request
            |> Ctypes.(!@)
            |> fun dir -> Ctypes.getf dir C.Types.File.Dir.dirents
          in
          Array.init
            (Request_.int_result request)
            (fun index ->
              Dirent.from_c Ctypes.(!@ (dirents +@ index))))
        (Request_.result request));
      immediate_error = Error.result_from_c;
      clean_up_request_on_success = true;
  }

  let returns_directory_scan = {
    from_request = (fun request ->
      Error.to_result_lazy
        (fun () -> Directory_scan.start request) (Request_.result request));
    immediate_error = Error.result_from_c;
    clean_up_request_on_success = false;
  }

  let returns_stat = {
    from_request = (fun request ->
      Error.to_result_lazy
        (fun () -> Stat.from_request request) (Request_.result request));
    immediate_error = Error.result_from_c;
    clean_up_request_on_success = true;
  }

  let returns_statfs = {
    from_request = (fun request ->
      Error.to_result_lazy
        (fun () -> Statfs.from_request request) (Request_.result request));
    immediate_error = Error.result_from_c;
    clean_up_request_on_success = true;
  }

  let returns_string = {
    from_request = (fun request ->
      Error.to_result_lazy
        (fun () -> C.Blocking.File.get_ptr_as_string request)
        (Request_.result request));
    immediate_error = Error.result_from_c;
    clean_up_request_on_success = true;
  }
end

module Args =
struct
  let uint i = fun f -> f (Unsigned.UInt.of_int i)

  let (!) v = fun f -> f v
  let (@@) a b = fun f -> b (a f)
end

type t = C.Types.File.t

let stdin = 0
let stdout = 1
let stderr = 2

module type ASYNC_OR_SYNC =
sig
  type 'value cps_or_normal_return
  type 'fn maybe_with_loop_and_request_arguments

  val async_or_sync :
    (Loop.t -> Request_.t -> 'c_signature) ->
    'result Returns.t ->
    ((('c_signature -> C.Blocking.File.trampoline -> int) ->
      (unit -> unit) ->
        'result cps_or_normal_return) ->
       'ocaml_signature) ->
      'ocaml_signature maybe_with_loop_and_request_arguments
end

module Make_functions (Async_or_sync : ASYNC_OR_SYNC) =
struct
  open Returns
  open Args

  let async_or_sync = Async_or_sync.async_or_sync
  let no_cleanup = ignore

  let open_ =
    async_or_sync
      C.Blocking.File.open_
      returns_file
      (fun run ?(mode = Mode.file_default) path flags ->
        let mode = Mode.list_to_c mode in
        let flags = Helpers.Bit_field.list_to_c Open_flag.to_c flags in
        run (!path @@ !flags @@ !mode) no_cleanup)

  let close =
    async_or_sync
      C.Blocking.File.close
      returns_error
      (fun run file -> run !file no_cleanup)

  let read_or_write c_function =
    async_or_sync
      c_function
      returns_byte_count
      (fun run ?(file_offset = -1L) file buffers ->
        let count = List.length buffers in
        let iovecs = Helpers.Buf.bigstrings_to_iovecs buffers count in
        run
          (!file @@ !(Ctypes.CArray.start iovecs) @@ uint count @@ !file_offset)
          (fun () ->
            let module Sys = Compatibility.Sys in
            ignore (Sys.opaque_identity buffers);
            ignore (Sys.opaque_identity iovecs)))

  let read = read_or_write C.Blocking.File.read
  let write = read_or_write C.Blocking.File.write

  let unlink =
    async_or_sync
      C.Blocking.File.unlink
      returns_error
      (fun run path -> run !path no_cleanup)

  let mkdir =
    async_or_sync
      C.Blocking.File.mkdir
      returns_error
      (fun run ?(mode = Mode.directory_default) path ->
        let mode = Mode.list_to_c mode in
        run (!path @@ !mode) no_cleanup)

  let mkdtemp =
    async_or_sync
      C.Blocking.File.mkdtemp
      returns_path
      (fun run path -> run !path no_cleanup)

  let mkstemp =
    async_or_sync
      C.Blocking.File.mkstemp
      returns_path_and_file
      (fun run path -> run !path no_cleanup)

  let rmdir =
    async_or_sync
      C.Blocking.File.rmdir
      returns_error
      (fun run path -> run !path no_cleanup)

  let opendir =
    async_or_sync
      C.Blocking.File.opendir
      returns_directory_handle
      (fun run path -> run !path no_cleanup)

  let closedir =
    async_or_sync
      C.Blocking.File.closedir
      returns_error
      (fun run dir -> run !dir no_cleanup)

  let readdir =
    async_or_sync
      C.Blocking.File.readdir
      returns_directory_entries
      (fun run ?(number_of_entries = 1024) dir ->
        let dirents =
          Ctypes.allocate_n C.Types.File.Dirent.t ~count:number_of_entries in
        let dir' = Ctypes.(!@) dir in
        Ctypes.setf dir' C.Types.File.Dir.dirents dirents;
        Ctypes.setf
          dir'
          C.Types.File.Dir.nentries
          (Unsigned.Size_t.of_int number_of_entries);
        run !dir (fun () ->
          ignore (Compatibility.Sys.opaque_identity dirents)))

  let scandir =
    async_or_sync
      C.Blocking.File.scandir
      returns_directory_scan
      (fun run path -> run (!path @@ !0) no_cleanup)

  let generic_stat c_function =
    async_or_sync
      c_function
      returns_stat
      (fun run argument -> run !argument no_cleanup)

  let stat = generic_stat C.Blocking.File.stat
  let lstat = generic_stat C.Blocking.File.lstat
  let fstat = generic_stat C.Blocking.File.fstat

  let statfs =
    async_or_sync
      C.Blocking.File.statfs
      returns_statfs
      (fun run path -> run !path no_cleanup)

  let rename =
    async_or_sync
      C.Blocking.File.rename
      returns_error
      (fun run from ~to_ -> run (!from @@ !to_) no_cleanup)

  let generic_fsync c_function =
    async_or_sync
      c_function
      returns_error
      (fun run file -> run !file no_cleanup)

  let fsync = generic_fsync C.Blocking.File.fsync
  let fdatasync = generic_fsync C.Blocking.File.fdatasync

  let ftruncate =
    async_or_sync
      C.Blocking.File.ftruncate
      returns_error
      (fun run file length -> run (!file @@ !length) no_cleanup)

  let copyfile =
    async_or_sync
      C.Blocking.File.copyfile
      returns_error
      (fun run
          ?(excl = false)
          ?(ficlone = false)
          ?(ficlone_force = false)
          from
          ~to_ ->
        let flags =
          let accumulate = Helpers.Bit_field.accumulate in
          0
          |> accumulate C.Types.File.Copy_flag.excl excl
          |> accumulate C.Types.File.Copy_flag.ficlone ficlone
          |> accumulate C.Types.File.Copy_flag.ficlone_force ficlone_force
        in
        run (!from @@ !to_ @@ !flags) no_cleanup)

  let sendfile =
    async_or_sync
      C.Blocking.File.sendfile
      returns_byte_count
      (fun run from ~to_ ~offset length ->
        run (!to_ @@ !from @@ !offset @@ !length) no_cleanup)

  let access =
    async_or_sync
      C.Blocking.File.access
      returns_error
      (fun run path mode ->
        let mode = Helpers.Bit_field.list_to_c Access_flag.to_c mode in
        run (!path @@ !mode) no_cleanup)

  let generic_chmod c_function =
    async_or_sync
      c_function
      returns_error
      (fun run argument mode ->
        let mode = Mode.list_to_c mode in
        run (!argument @@ !mode) no_cleanup)

  let chmod = generic_chmod C.Blocking.File.chmod
  let fchmod = generic_chmod C.Blocking.File.fchmod

  let generic_utime c_function =
    async_or_sync
      c_function
      returns_error
      (fun run argument ~atime ~mtime ->
        run (!argument @@ !atime @@ !mtime) no_cleanup)

  let utime = generic_utime C.Blocking.File.utime
  let futime = generic_utime C.Blocking.File.futime

  let link =
    async_or_sync
      C.Blocking.File.link
      returns_error
      (fun run target ~link -> run (!target @@ !link) no_cleanup)

  let symlink =
    async_or_sync
      C.Blocking.File.symlink
      returns_error
      (fun run ?(dir = false) ?(junction = false) target ~link ->
        let flags =
          let accumulate = Helpers.Bit_field.accumulate in
          0
          |> accumulate C.Types.File.Symlink_flag.dir dir
          |> accumulate C.Types.File.Symlink_flag.junction junction
        in
        run (!target @@ !link @@ !flags) no_cleanup)

  let generic_readpath c_function =
    async_or_sync
      c_function
      returns_string
      (fun run path -> run !path no_cleanup)

  let readlink = generic_readpath C.Blocking.File.readlink
  let realpath = generic_readpath C.Blocking.File.realpath

  let generic_chown c_function =
    async_or_sync
      c_function
      returns_error
      (fun run argument ~uid ~gid -> run (!argument @@ !uid @@ !gid) no_cleanup)

  let chown = generic_chown C.Blocking.File.chown
  let fchown = generic_chown C.Blocking.File.fchown
  let lchown = generic_chown C.Blocking.File.lchown
end

module Async =
struct
  let trampoline =
    C.Blocking.File.get_trampoline ()

  let async c_function returns get_args =
    fun ?loop ?request ->
      get_args begin fun args cleanup callback ->
        let loop = Loop.or_default loop in
        let request = Request_.or_make request in

        let callback = Error.catch_exceptions callback in
        Request.set_callback request begin fun () ->
          let result = Returns.(returns.from_request request) in
          if Returns.(returns.clean_up_request_on_success)
            || Request_.result request < 0 then begin
            Request_.cleanup request
          end;
          cleanup ();
          callback result
        end;

        let immediate_result =
          ((c_function loop request) |> args) trampoline in

        if immediate_result < 0 then begin
          Request.release request;
          Request_.cleanup request;
          cleanup ();
          callback (Returns.(returns.immediate_error) immediate_result)
        end
      end

  include Make_functions
    (struct
      type 'value cps_or_normal_return = ('value -> unit) -> unit
      type 'fn maybe_with_loop_and_request_arguments =
        ?loop:Loop.t -> ?request:Request_.t -> 'fn
      let async_or_sync = async
    end)
end

include Async

module Sync =
struct
  let null_callback =
    C.Blocking.File.get_null_callback ()

  let sync c_function returns get_args =
    get_args begin fun args cleanup ->
      let request = Request_.make () in
      Request.release request;
      let immediate_result =
        ((c_function (Loop.default ()) request) |> args)
          null_callback
      in

      cleanup ();
      let result =
        if immediate_result < 0 then
          Returns.(returns.immediate_error) immediate_result
        else
          Returns.(returns.from_request) request
      in
      if Returns.(returns.clean_up_request_on_success)
        || immediate_result < 0 then begin
        Request_.cleanup request;
      end;
      result
    end

  include Make_functions
    (struct
      type 'value cps_or_normal_return = 'value
      type 'fn maybe_with_loop_and_request_arguments = 'fn
      let async_or_sync = sync
    end)
end

module Request = Request_

let get_osfhandle file =
  let handle = C.Functions.Os_fd.get_osfhandle file in
  Result.Ok handle

let open_osfhandle handle =
  let file = C.Functions.Os_fd.open_osfhandle handle in
  if file = -1 then
    Result.Error `EBADF
  else
    Result.Ok file

let to_int file =
  file
