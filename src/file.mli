(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** File operations.

    See {{:https://aantron.github.io/luv/filesystem.html} {i Filesystem}} in the
    user guide and  {{:http://docs.libuv.org/en/v1.x/fs.html} {i File system
    operations}} in libuv.

    This module exposes all the filesystem operations of libuv with an
    asynchronous (callback) interface. There is an additional submodule,
    {!Luv.File.Sync}, which exposes all the same operations with a synchronous
    (direct) interface. So, for example, there are:

    {[
      Luv.File.chmod :
        string -> Mode.t list -> ((unit, Error.t) result -> unit) -> unit

      Luv.File.Sync.chmod :
        string -> Mode.t list -> (unit, Error.t) result
    ]}

    For filesystem operations, synchronous operations are generally faster,
    because most asynchronous operations have to be run in a worker thread.
    However, synchronous operations can block.

    A general guideline is that if performance is not critical, or your code may
    be used to access a network filesystem, use asynchronous operations. The
    latter condition may be especially important if you are writing a library,
    and cannot readily predict whether it will be used to access a network file
    system or not.

    Synchronous operations are typically best for internal applications and
    short scripts.

    It is possible to run a sequence of synchronous operations without blocking
    the main thread by manually running them in a worker. This can be done in
    several ways:

    - Directly using the {{!Luv.Thread.Pool} libuv thread pool}.
    - By creating a thread manually with {!Luv.Thread.create}.
    - By creating a thread manually with OCaml's standard
      {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Thread.html}
      [Thread]} module.

    This is only worthwhile if multiple synchronous operations will be done
    inside the worker thread. If the worker thread does only one operation, the
    performance is identical to the asynchronous API.

    Note that this performance difference does not apply to other kinds of libuv
    operations. For example, unlike reading from a file, reading from the
    network asynchronously is very fast. *)



(** {1 Types} *)

type t
(** Files.

    Roughly, on Unix, these correspond to OS file descriptors, and on Windows,
    these are [HANDLE]s wrapped in C runtime file descriptors. *)

(** {{!Luv.File.Request} Request objects} that can be optionally used with this
    module.

    This is a binding to {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_t}
    [uv_fs_t]}.

    By default, request objects are managed internally by Luv, and the user does
    not need to be aware of them. The only purpose of exposing them in the API
    is to allow the user to {{!Luv.Request.cancel} cancel} filesystem
    operations.

    All functions in this module that start asynchronous operations take a
    reference to a request object in a [?request] optional argument. If the user
    does provide a request object, Luv will use that object for the operation,
    instead of creating a fresh request object internally. The user can then
    cancel the operation by calling {!Luv.Request.cancel} on the request:

    {[
      let request = Luv.File.Request.make () in
      Luv.File.chmod ~request "foo" [`IRUSR] ignore;
      ignore (Luv.Request.cancel request);
    ]}

    This mechanism is entirely optional. If cancelation is not needed, the code
    reduces to simply

    {[
      Luv.File.chmod "foo" [`IRUSR] ignore;
    ]} *)
module Request :
sig
  type t = [ `File ] Request.t
  val make : unit -> t
end



(** {1 Standard I/O streams} *)

val stdin : t
val stdout : t
val stderr : t



(** {1 Basics} *)

(** {{!Luv.File.Open_flag} Flags} for use with {!Luv.File.open_}. See the flags
    in {{:http://man7.org/linux/man-pages/man3/open.3p.html#DESCRIPTION}
    [open(3p)]}. *)
module Open_flag :
sig
  type t = [
    (* Access mode. *)
    | `RDONLY
    | `WRONLY
    | `RDWR

    (* Creation flags. *)
    | `CREAT
    | `EXCL
    | `EXLOCK
    | `NOCTTY
    | `NOFOLLOW
    | `TEMPORARY
    | `TRUNC

    (* Status flags. *)
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
end

(** {{!Luv.File.Mode} Permissions bits}. *)
module Mode :
sig
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

(* TODO: Not supported on Windows.
    | `ISUID
    | `ISGID
    | `ISVTX
*)

    | `NUMERIC of int
  ]
  (** The bits.

      These are accepted by operations such as {!Luv.File.chmod} in lists, e.g.

      {[
        [`IRUSR; `IWUSR; `IRGRP; `IROTH]
      ]}

      The special constructor [`NUMERIC] can be
      used to specify bits directly in octal. The above list is equivalent to:

      {[
        [`NUMERIC 0o644]
      ]} *)

  type numeric
  (** Abstract type for a bit field of permissions bits, i.e., an [int] in which
      multiple bits may be set. These bit fields are returned by operations such
      as {!Luv.File.stat}. *)

  val test : t list -> numeric -> bool
  (** [Luv.File.Mode.test mask bits] checks whether all the bits in [mask] are
      set in [bits]. For example, if [bits] contains [0o644],
      [Luv.File.Mode.test [`IRUSR] bits] evaluates to [true]. *)
end

val open_ :
  ?loop:Loop.t ->
  ?request:Request.t ->
  ?mode:Mode.t list ->
  string ->
  Open_flag.t list ->
  ((t, Error.t) result -> unit) ->
    unit
(** Opens the file at the given path.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_open} [uv_fs_open]}.
    See {{:http://man7.org/linux/man-pages/man3/open.3p.html} [open(3p)]}. The
    synchronous version is {!Luv.File.Sync.open_}.

    The default value of the [?mode] argument is [[`NUMERIC 0o644]]. *)

val close :
  ?loop:Loop.t ->
  ?request:Request.t ->
  t ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Closes the given file.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_close}
    [uv_fs_close]}. See {{:http://man7.org/linux/man-pages/man3/close.3p.html}
    [close(3p)]}. The synchronous version is {!Luv.File.Sync.close}. *)

val read :
  ?loop:Loop.t ->
  ?request:Request.t ->
  ?file_offset:int64 ->
  t ->
  Buffer.t list ->
  ((Unsigned.Size_t.t, Error.t) result -> unit) ->
    unit
(** Reads from the given file.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_read} [uv_fs_read]}.
    See {{:http://man7.org/linux/man-pages/man3/readv.3p.html} [readv(3p)]}. The
    synchronous version is {!Luv.File.Sync.read}.

    The incoming data is written consecutively to into the given buffers. The
    number of bytes that the operation tries to read is the total length of the
    buffers.

    If you have a buffer a ready, but would like to read less bytes than the
    length of the buffer, use
    {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Bigarray.Array1.html#VALsub}
    [Bigarray.Array1.sub]} or {!Luv.Buffer.sub} to create a shorter view of the
    buffer.

    If the [?file_offset] argument is not specified, the read is done at the
    current offset into the file, and the file offset is updated. Otherwise, a
    positioned read is done at the given offset, and the file offset is not
    updated. See {{:http://man7.org/linux/man-pages/man3/pread.3p.html}
    [pread(3p)]}.

    End of file is indicated by [Ok Unsigned.Size_t.zero]. Note that this is
    different from {!Luv.Stream.read_start}. *)

val write :
  ?loop:Loop.t ->
  ?request:Request.t ->
  ?file_offset:int64 ->
  t ->
  Buffer.t list ->
  ((Unsigned.Size_t.t, Error.t) result -> unit) ->
    unit
(** Writes to the given file.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_write}
    [uv_fs_write]}. See {{:http://man7.org/linux/man-pages/man3/writev.3p.html}
    [writev(3p)]}. The synchronous version is {!Luv.File.Sync.write}.

    See {!Luv.File.read} for notes on the lengths of the buffers and the meaning
    of [?file_offset]. *)



(** {1 Moving and removing} *)

val unlink :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Deletes the file at the given path.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_unlink}
    [uv_fs_unlink]}. See {{:http://man7.org/linux/man-pages/man3/unlink.3p.html}
    [unlink(3p)]}. The synchronous version is {!Luv.File.Sync.unlink}. *)

val rename :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  to_:string ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Moves the file at the given path to the path given by [~to_].

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_rename}
    [uv_fs_rename]}. See {{:http://man7.org/linux/man-pages/man3/rename.3p.html}
    [rename(3p)]}. The synchronous version is {!Luv.File.Sync.rename}. *)



(** {1 Temporary files} *)

val mkstemp :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  ((string * t, Error.t) result -> unit) ->
    unit
(** Creates a temporary file with name based on the given pattern.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_mkstemp}
    [uv_fs_mkstemp]}. See
    {{:http://man7.org/linux/man-pages/man3/mkdtemp.3p.html} [mkstemp(3p)]}. The
    synchronous version is {!Luv.File.Sync.mkstemp}. *)

val mkdtemp :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  ((string, Error.t) result -> unit) ->
    unit
(** Creates a temporary directory with name based on the given pattern.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_mkdtemp}
    [uv_fs_mkdtemp]}. See
    {{:http://man7.org/linux/man-pages/man3/mkdtemp.3p.html} [mkdtemp(3p)]}. The
    synchronous version is {!Luv.File.Sync.mkdtemp}. *)



(** {1 Directories} *)

val mkdir :
  ?loop:Loop.t ->
  ?request:Request.t ->
  ?mode:Mode.t list ->
  string ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Creates a directory.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_mkdir}
    [uv_fs_mkdir]}. See {{:http://man7.org/linux/man-pages/man3/mkdir.3p.html}
    [mkdir(3p)]}. The synchronous version is {!Luv.File.Sync.mkdir}.

    The default value of the [?mode] argument is [[`NUMERIC 0o755]]. *)

val rmdir :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Deletes a directory.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_rmdir}
    [uv_fs_rmdir]}. See {{:http://man7.org/linux/man-pages/man3/rmdir.3p.html}
    [rmdir(3p)]}. The synchronous version is {!Luv.File.Sync.rmdir}. *)

(** Directory entries. Binds
    {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_dirent_t} [uv_dirent_t]}. *)
module Dirent :
sig
  module Kind :
  sig
    type t = [
      | `UNKNOWN
      | `FILE
      | `DIR
      | `LINK
      | `FIFO
      | `SOCKET
      | `CHAR
      | `BLOCK
    ]
  end

  type t = {
    kind : Kind.t;
    name : string;
  }
end

(** Declares only {!Luv.File.Dir.t}, which binds
    {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_dir_t} [uv_dir_t]}. *)
module Dir :
sig
  type t
end

val opendir :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  ((Dir.t, Error.t) result -> unit) ->
    unit
(** Opens the directory at the given path for listing.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_opendir}
    [uv_fs_opendir]}. See
    {{:http://man7.org/linux/man-pages/man3/fdopendir.3p.html} [opendir(3p)]}.
    The synchronous version is {!Luv.File.Sync.opendir}.

    The directory must later be closed with {!Luv.File.closedir}. *)

val closedir :
  ?loop:Loop.t ->
  ?request:Request.t ->
  Dir.t ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Closes the given directory.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_closedir}
    [uv_fs_closedir]}. See
    {{:http://man7.org/linux/man-pages/man3/closedir.3p.html} [closedir(3p)]}.
    The synchronous version is {!Luv.File.Sync.closedir}. *)

val readdir :
  ?loop:Loop.t ->
  ?request:Request.t ->
  ?number_of_entries:int ->
  Dir.t ->
  ((Dirent.t array, Error.t) result -> unit) ->
    unit
(** Retrieves a directory entry.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_readdir}
    [uv_fs_readdir]}. See
    {{:http://man7.org/linux/man-pages/man3/readdir.3p.html} [readdir(3p)]}. The
    synchronous version is {!Luv.File.Sync.readdir}. *)

(** Abstract type of of directory scans. See {!Luv.File.scandir}. *)
module Directory_scan :
sig
  type t
end

val scandir :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  ((Directory_scan.t, Error.t) result -> unit) ->
    unit
(** Begins directory listing.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_scandir}
    [uv_fs_scandir]}. See
    {{:http://man7.org/linux/man-pages/man3/scandir.3p.html} [scandir(3p)]}. The
    synchronous version is {!Luv.File.Sync.scandir}.

    The resulting value of type [Directory_scan.t] must be cleaned up by calling
    {!Luv.File.scandir_end}. *)

val scandir_next :
  Directory_scan.t ->
    Dirent.t option
(** Retrieves the next directory entry.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_scandir_next}
    [uv_fs_scandir_next]}. *)

val scandir_end :
  Directory_scan.t ->
    unit
(** Cleans up after a directory scan. *)



(** {1 Status} *)

(** Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_stat_t} [uv_stat_t]}. *)
module Stat :
sig
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

  (**/**)

  val load : C.Types.File.Stat.t -> t
end

val stat :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  ((Stat.t, Error.t) result -> unit) ->
    unit
(** Retrieves status information for the file at the given path.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_stat} [uv_fs_stat]}.
    See {{:http://man7.org/linux/man-pages/man3/fstatat.3p.html} [stat(3p)]}.
    The synchronous version is {!Luv.File.Sync.stat}. *)

val lstat :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  ((Stat.t, Error.t) result -> unit) ->
    unit
(** Like {!Luv.File.stat}, but does not dereference symlinks.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_lstat}
    [uv_fs_lstat]}. See {{:http://man7.org/linux/man-pages/man3/fstatat.3p.html}
    [lstat(3p)]}. The synchronous version is {!Luv.File.Sync.lstat}. *)

val fstat :
  ?loop:Loop.t ->
  ?request:Request.t ->
  t ->
  ((Stat.t, Error.t) result -> unit) ->
    unit
(** Like {!Luv.File.stat}, but takes a file instead of a path.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_fstat}
    [uv_fs_fstat]}. See {{:http://man7.org/linux/man-pages/man3/fstatat.3p.html}
    [fstat(3p)]}. The synchronous version is {!Luv.File.Sync.fstat}. *)

(** Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_statfs_t}
    [uv_statfs_t]}. *)
module Statfs :
sig
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
end

val statfs :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  ((Statfs.t, Error.t) result -> unit) ->
    unit
(** Retrieves status information for the filesystem containing the given path.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_statfs}
    [uv_fs_statfs]}. See {{:http://man7.org/linux/man-pages/man2/statfs.2.html}
    [statfs(2)]}. The synchronous version is {!Luv.File.Sync.statfs}. *)



(** {1 Flushing} *)

val fsync :
  ?loop:Loop.t ->
  ?request:Request.t ->
  t ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Flushes file changes to storage.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_fsync}
    [uv_fs_fsync]}. See {{:http://man7.org/linux/man-pages/man3/fsync.3p.html}
    [fsync(3p)]}. The synchronous version is {!Luv.File.Sync.fsync}. *)

val fdatasync :
  ?loop:Loop.t ->
  ?request:Request.t ->
  t ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Like {!Luv.File.fsync}, but may omit some metadata.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_fdatasync}
    [uv_fs_fdatasync]}. See
    {{:http://man7.org/linux/man-pages/man2/fdatasync.2.html} [fdatasync(2)]}.
    The synchronous version is {!Luv.File.Sync.fdatasync}. *)



(** {1 Transfers} *)

val ftruncate :
  ?loop:Loop.t ->
  ?request:Request.t ->
  t ->
  int64 ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Truncates the given file to the given length.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_ftruncate}
    [uv_fs_ftruncate]}. See
    {{:http://man7.org/linux/man-pages/man3/ftruncate.3p.html}
    [ftruncate(3p)]}. The synchronous version is {!Luv.File.Sync.ftruncate}. *)

val copyfile :
  ?loop:Loop.t ->
  ?request:Request.t ->
  ?excl:bool ->
  ?ficlone:bool ->
  ?ficlone_force:bool ->
  string ->
  to_:string ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Copies the file at the given path to the path given by [~to_].

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_copyfile}
    [uv_fs_copyfile]}. The synchronous version is {!Luv.File.Sync.copyfile}. *)

val sendfile :
  ?loop:Loop.t ->
  ?request:Request.t ->
  t ->
  to_:t ->
  offset:int64 ->
  Unsigned.Size_t.t ->
  ((Unsigned.Size_t.t, Error.t) result -> unit)  ->
    unit
(** Transfers data between file descriptors.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_sendfile}
    [uv_fs_sendfile]}. See
    {{:http://man7.org/linux/man-pages/man2/sendfile.2.html} [sendfile(2)]}.
    The synchronous version is {!Luv.File.Sync.sendfile}. *)



(** {1 Permissions} *)

(** Declares [`F_OK], [`R_OK], [`W_OK], [`X_OK] for use with
    {!Luv.File.access}. *)
module Access_flag :
sig
  type t = [
    | `F_OK
    | `R_OK
    | `W_OK
    | `X_OK
  ]
end

val access :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  Access_flag.t list ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Checks whether the calling process can access the file at the given path.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_access}
    [uv_fs_access]}. See
    {{:http://man7.org/linux/man-pages/man3/access.3p.html} [access(3p)]}. The
    synchronous version is {!Luv.File.Sync.access}. *)

val chmod :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  Mode.t list ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Changes permissions of the file at the given path.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_chmod}
    [uv_fs_chmod]}. See
    {{:http://man7.org/linux/man-pages/man3/chmod.3p.html} [chmod(3p)]}. The
    synchronous version is {!Luv.File.Sync.chmod}. *)

val fchmod :
  ?loop:Loop.t ->
  ?request:Request.t ->
  t ->
  Mode.t list ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Like {!Luv.File.chmod}, but takes a file instead of a path.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_fchmod}
    [uv_fs_fchmod]}. See
    {{:http://man7.org/linux/man-pages/man3/fchmod.3p.html} [fchmod(3p)]}. The
    synchronous version is {!Luv.File.Sync.fchmod}. *)



(** {1 Timestamps} *)

val utime :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  atime:float ->
  mtime:float ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Sets timestamps of the file at the given path.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_utime}
    [uv_fs_utime]}. See {{:http://man7.org/linux/man-pages/man3/utime.3p.html}
    [utime(3p)]}. The synchronous version is {!Luv.File.Sync.utime}. *)

val futime :
  ?loop:Loop.t ->
  ?request:Request.t ->
  t ->
  atime:float ->
  mtime:float ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Like {!Luv.File.utime}, but takes a file instead of a path.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_futime}
    [uv_fs_futime]}. See {{:http://man7.org/linux/man-pages/man3/futime.3p.html}
    [futime(3p)]}. The synchronous version is {!Luv.File.Sync.futime}. *)



(** {1 Links} *)

val link :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  link:string ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Hardlinks a file at the location given by [~link].

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_link} [uv_fs_link]}.
    See {{:http://man7.org/linux/man-pages/man3/link.3p.html} [link(3p)]}. The
    synchronous version is {!Luv.File.Sync.link}. *)

val symlink :
  ?loop:Loop.t ->
  ?request:Request.t ->
  ?dir:bool ->
  ?junction:bool ->
  string ->
  link:string ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Symlinks a file at the location given by [~link].

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_symlink}
    [uv_fs_symlink]}. See
    {{:http://man7.org/linux/man-pages/man3/symlink.3p.html} [symlink(3p)]}. The
    synchronous version is {!Luv.File.Sync.symlink}.

    See {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_symlink}
    [uv_fs_symlink]} for the meaning of the optional arguments. *)

val readlink :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  ((string, Error.t) result -> unit) ->
    unit
(** Reads the target path of a symlink.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_readlink}
    [uv_fs_readlink]}. See
    {{:http://man7.org/linux/man-pages/man3/readlink.3p.html} [readlink(3p)]}.
    The synchronous version is {!Luv.File.Sync.readlink}. *)

val realpath :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  ((string, Error.t) result -> unit) ->
    unit
(** Resolves a real absolute path to the given file.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_realpath}
    [uv_fs_readpath]}. See
    {{:http://man7.org/linux/man-pages/man3/realpath.3p.html} [realpath(3p)]}.
    The synchronous version is {!Luv.File.Sync.realpath}. *)



(** {1 Ownership} *)

val chown :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  uid:int ->
  gid:int ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Changes owneship of the file at the given path.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_chown}
    [uv_fs_chown]}. See
    {{:http://man7.org/linux/man-pages/man3/chown.3p.html} [chown(3p)]}. The
    synchronous version is {!Luv.File.Sync.chown}. *)

val lchown :
  ?loop:Loop.t ->
  ?request:Request.t ->
  string ->
  uid:int ->
  gid:int ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Like {!Luv.File.chown}, but does not dereference symlinks.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_lchown}
    [uv_fs_lchown]}. See
    {{:http://man7.org/linux/man-pages/man3/lchown.3p.html} [lchown(3p)]}. The
    synchronous version is {!Luv.File.Sync.lchown}. *)

val fchown :
  ?loop:Loop.t ->
  ?request:Request.t ->
  t ->
  uid:int ->
  gid:int ->
  ((unit, Error.t) result -> unit) ->
    unit
(** Like {!Luv.File.chown}, but takes a file instead of a path.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_fs_fchown}
    [uv_fs_fchown]}. See
    {{:http://man7.org/linux/man-pages/man3/fchown.3p.html} [fchown(3p)]}. The
    synchronous version is {!Luv.File.Sync.fchown}. *)



(** {1 Synchronous API} *)

module Sync :
sig
  val open_ :
    ?mode:Mode.t list -> string -> Open_flag.t list ->
      (t, Error.t) result
  (** Synchronous version of {!Luv.File.open_}. *)

  val close :
    t ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.close}. *)

  val read :
    ?file_offset:int64 -> t -> Buffer.t list ->
      (Unsigned.Size_t.t, Error.t) result
  (** Synchronous version of {!Luv.File.read}. *)

  val write :
    ?file_offset:int64 -> t -> Buffer.t list ->
      (Unsigned.Size_t.t, Error.t) result
  (** Synchronous version of {!Luv.File.write}. *)

  val unlink :
    string ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.unlink}. *)

  val rename :
    string -> to_:string ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.rename}. *)

  val mkstemp :
    string ->
      (string * t, Error.t) result
  (** Synchronous version of {!Luv.File.mkstemp}. *)

  val mkdtemp :
    string ->
      (string, Error.t) result
  (** Synchronous version of {!Luv.File.mkdtemp}. *)

  val mkdir :
    ?mode:Mode.t list -> string ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.mkdir}. *)

  val rmdir :
    string ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.rmdir}. *)

  val opendir :
    string ->
      (Dir.t, Error.t) result
  (** Synchronous version of {!Luv.File.opendir}. *)

  val closedir :
    Dir.t ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.closedir}. *)

  val readdir :
    ?number_of_entries:int -> Dir.t ->
      (Dirent.t array, Error.t) result
  (** Synchronous version of {!Luv.File.readdir}. *)

  val scandir :
    string ->
      (Directory_scan.t, Error.t) result
  (** Synchronous version of {!Luv.File.scandir}. *)

  val stat :
    string ->
      (Stat.t, Error.t) result
  (** Synchronous version of {!Luv.File.stat}. *)

  val lstat :
    string ->
      (Stat.t, Error.t) result
  (** Synchronous version of {!Luv.File.lstat}. *)

  val fstat :
    t ->
      (Stat.t, Error.t) result
  (** Synchronous version of {!Luv.File.fstat}. *)

  val statfs :
    string ->
      (Statfs.t, Error.t) result
  (** Synchronous version of {!Luv.File.statfs}. *)

  val fsync :
    t ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.fsync}. *)

  val fdatasync :
    t ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.fdatasync}. *)

  val ftruncate :
    t -> int64 ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.ftruncate}. *)

  val copyfile :
    ?excl:bool ->
    ?ficlone:bool ->
    ?ficlone_force:bool ->
    string ->
    to_:string ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.copyfile}. *)

  val sendfile :
    t -> to_:t -> offset:int64 -> Unsigned.Size_t.t ->
      (Unsigned.Size_t.t, Error.t) result
  (** Synchronous version of {!Luv.File.sendfile}. *)

  val access :
    string -> Access_flag.t list ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.access}. *)

  val chmod :
    string -> Mode.t list ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.chmod}. *)

  val fchmod :
    t -> Mode.t list ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.fchmod}. *)

  val utime :
    string -> atime:float -> mtime:float ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.utime}. *)

  val futime :
    t -> atime:float -> mtime:float ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.futime}. *)

  val link :
    string -> link:string ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.link}. *)

  val symlink :
    ?dir:bool -> ?junction:bool -> string -> link:string ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.symlink}. *)

  val readlink :
    string ->
      (string, Error.t) result
  (** Synchronous version of {!Luv.File.readlink}. *)

  val realpath :
    string ->
      (string, Error.t) result
  (** Synchronous version of {!Luv.File.realpath}. *)

  val chown :
    string -> uid:int -> gid:int ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.chown}. *)

  val lchown :
    string -> uid:int -> gid:int ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.lchown}. *)

  val fchown :
    t -> uid:int -> gid:int ->
      (unit, Error.t) result
  (** Synchronous version of {!Luv.File.fchown}. *)
end



(** {1 Conversions} *)

val get_osfhandle : t -> (Os_fd.Fd.t, Error.t) result
(** Converts a {!Luv.File.t} to an OS file handle.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_get_osfhandle}
    [uv_get_osfhandle]}. See
    {{:https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/get-osfhandle}
    [_get_osfhandle]}.

    On Unix-like systems, this passes the file descriptor through unchanged. On
    Windows, a {!Luv.File.t} is an C runtime library file descritpor. This
    function converts it to a [HANDLE]. *)

val open_osfhandle : Os_fd.Fd.t -> (t, Error.t) result
(** Inverse of {!Luv.File.get_osfhandle}.

    Binds {{:http://docs.libuv.org/en/v1.x/fs.html#c.uv_open_osfhandle}
    [uv_open_osfhandle]}. See
    {{:https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/open-osfhandle}
    [_open_osfhandle]}. *)

val to_int : t -> int
(** Returns the integer representation of a {!Luv.File.t}.

    {!Luv.File.t} is defined as an integer file descriptor by libuv on all
    platforms at the moment. This is a convenience function for interoperability
    with {!Luv.Process}, the API of which assumes that files are represented by
    integers. *)
