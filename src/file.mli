module Open_flag :
sig
  type t

  (* Access mode. *)
  val rdonly : t
  val wronly : t
  val rdwr : t

  (* Creation flags. *)
  val creat : t
  val excl : t
  val exlock : t
  val noctty : t
  val nofollow : t
  val temporary : t
  val trunc : t

  (* Status flags. *)
  val append : t
  val direct : t
  val dsync : t
  val noatime : t
  val nonblock : t
  val random : t
  val sequential : t
  val short_lived : t
  val symlink : t
  val sync : t

  val list : t list -> t
  val custom : int -> t
  val (lor) : t -> t -> t
end

module Mode :
sig
  type t = private int

  val none : t

  val irwxu : t
  val irusr : t
  val iwusr : t
  val ixusr : t

  val irwxg : t
  val irgrp : t
  val iwgrp : t
  val ixgrp : t

  val irwxo : t
  val iroth : t
  val iwoth : t
  val ixoth : t

  val isuid : t
  val isgid : t
  val isvtx : t

  val list : t list -> t
  val octal : int -> t
  val (lor) : t -> t -> t
end

module Dirent :
sig
  module Kind :
  sig
    type t

    val unknown : t
    val file : t
    val dir : t
    val link : t
    val fifo : t
    val socket : t
    val char : t
    val block : t
  end

  type t = {
    kind : Kind.t;
    name : string;
  }
end

(* DOC This requires some memory management on the user's part. *)
module Directory_scan :
sig
  type t

  val next : t -> Dirent.t option
  val stop : t -> unit
end

module Stat :
sig
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
end

module Copy_flag :
sig
  type t

  val none : t

  val excl : t
  val ficlone : t
  val ficlone_force : t

  val list : t list -> t
  val (lor) : t -> t -> t
end

module Access_flag :
sig
  type t

  val f : t
  val r : t
  val w : t
  val x : t

  val list : t list -> t
  val (lor) : t -> t -> t
end

module Symlink_flag :
sig
  type t

  val none : t

  val dir : t
  val junction : t

  val list : t list -> t
  val (lor) : t -> t -> t
end

module Request :
sig
  type t = [ `File ] Request.t
  val make : unit -> t
end

type t

module Async :
sig
  val open_ :
    ?loop:Loop.t ->
    ?request:Request.t ->
    ?mode:Mode.t ->
    string ->
    Open_flag.t ->
    ((t, Error.t) Result.result -> unit) ->
      unit

  val close :
    ?loop:Loop.t ->
    ?request:Request.t ->
    t ->
    (Error.t -> unit) ->
      unit

  val read :
    ?loop:Loop.t ->
    ?request:Request.t ->
    ?offset:int64 ->
    t ->
    Bigstring.t list ->
    ((Unsigned.Size_t.t, Error.t) Result.result -> unit) ->
      unit

  val write :
    ?loop:Loop.t ->
    ?request:Request.t ->
    ?offset:int64 ->
    t ->
    Bigstring.t list ->
    ((Unsigned.Size_t.t, Error.t) Result.result -> unit) ->
      unit

  val unlink :
    ?loop:Loop.t ->
    ?request:Request.t ->
    string ->
    (Error.t -> unit) ->
      unit

  val mkdir :
    ?loop:Loop.t ->
    ?request:Request.t ->
    ?mode:Mode.t ->
    string ->
    (Error.t -> unit) ->
      unit

  val mkdtemp :
    ?loop:Loop.t ->
    ?request:Request.t ->
    string ->
    ((string, Error.t) Result.result -> unit) ->
      unit

  val rmdir :
    ?loop:Loop.t ->
    ?request:Request.t ->
    string ->
    (Error.t -> unit) ->
      unit

  val scandir :
    ?loop:Loop.t ->
    ?request:Request.t ->
    string ->
    ((Directory_scan.t, Error.t) Result.result -> unit) ->
      unit

  val stat :
    ?loop:Loop.t ->
    ?request:Request.t ->
    string ->
    ((Stat.t, Error.t) Result.result -> unit) ->
      unit

  val lstat :
    ?loop:Loop.t ->
    ?request:Request.t ->
    string ->
    ((Stat.t, Error.t) Result.result -> unit) ->
      unit

  val fstat :
    ?loop:Loop.t ->
    ?request:Request.t ->
    t ->
    ((Stat.t, Error.t) Result.result -> unit) ->
      unit

  val rename :
    ?loop:Loop.t ->
    ?request:Request.t ->
    from:string ->
    to_:string ->
    (Error.t -> unit) ->
      unit

  val fsync :
    ?loop:Loop.t ->
    ?request:Request.t ->
    t ->
    (Error.t -> unit) ->
      unit

  val fdatasync :
    ?loop:Loop.t ->
    ?request:Request.t ->
    t ->
    (Error.t -> unit) ->
      unit

  val ftruncate :
    ?loop:Loop.t ->
    ?request:Request.t ->
    t ->
    int64 ->
    (Error.t -> unit) ->
      unit

  val copyfile :
    ?loop:Loop.t ->
    ?request:Request.t ->
    from:string ->
    to_:string ->
    Copy_flag.t ->
    (Error.t -> unit) ->
      unit

  val sendfile :
    ?loop:Loop.t ->
    ?request:Request.t ->
    to_:t ->
    from:t ->
    offset:int64 ->
    Unsigned.Size_t.t ->
    ((Unsigned.Size_t.t, Error.t) Result.result -> unit)  ->
      unit

  val access :
    ?loop:Loop.t ->
    ?request:Request.t ->
    string ->
    Access_flag.t ->
    (Error.t -> unit) ->
      unit

  val chmod :
    ?loop:Loop.t ->
    ?request:Request.t ->
    string ->
    Mode.t ->
    (Error.t -> unit) ->
      unit

  val fchmod :
    ?loop:Loop.t ->
    ?request:Request.t ->
    t ->
    Mode.t ->
    (Error.t -> unit) ->
      unit

  val utime :
    ?loop:Loop.t ->
    ?request:Request.t ->
    string ->
    atime:float ->
    mtime:float ->
    (Error.t -> unit) ->
      unit

  val futime :
    ?loop:Loop.t ->
    ?request:Request.t ->
    t ->
    atime:float ->
    mtime:float ->
    (Error.t -> unit) ->
      unit

  val link :
    ?loop:Loop.t ->
    ?request:Request.t ->
    target:string ->
    link:string ->
    (Error.t -> unit) ->
      unit

  val symlink :
    ?loop:Loop.t ->
    ?request:Request.t ->
    target:string ->
    link:string ->
    Symlink_flag.t ->
    (Error.t -> unit) ->
      unit

  val readlink :
    ?loop:Loop.t ->
    ?request:Request.t ->
    string ->
    ((string, Error.t) Result.result -> unit) ->
      unit

  val realpath :
    ?loop:Loop.t ->
    ?request:Request.t ->
    string ->
    ((string, Error.t) Result.result -> unit) ->
      unit

  val chown :
    ?loop:Loop.t ->
    ?request:Request.t ->
    string ->
    uid:int ->
    gid:int ->
    (Error.t -> unit) ->
      unit

  val fchown :
    ?loop:Loop.t ->
    ?request:Request.t ->
    t ->
    uid:int ->
    gid:int ->
    (Error.t -> unit) ->
      unit

  val lchown :
    ?loop:Loop.t ->
    ?request:Request.t ->
    string ->
    uid:int ->
    gid:int ->
    (Error.t -> unit) ->
      unit
end

module Sync :
sig
  val open_ :
    ?mode:Mode.t -> string -> Open_flag.t ->
      (t, Error.t) Result.result

  val close :
    t ->
      Error.t

  val read :
    ?offset:int64 -> t -> Bigstring.t list ->
      (Unsigned.Size_t.t, Error.t) Result.result

  val write :
    ?offset:int64 -> t -> Bigstring.t list ->
      (Unsigned.Size_t.t, Error.t) Result.result

  val unlink :
    string ->
      Error.t

  val mkdir :
    ?mode:Mode.t -> string ->
      Error.t

  val mkdtemp :
    string ->
      (string, Error.t) Result.result

  val rmdir :
    string ->
      Error.t

  val scandir :
    string ->
      (Directory_scan.t, Error.t) Result.result

  val stat :
    string ->
      (Stat.t, Error.t) Result.result

  val lstat :
    string ->
      (Stat.t, Error.t) Result.result

  val fstat :
    t ->
      (Stat.t, Error.t) Result.result

  val rename :
    from:string -> to_:string ->
      Error.t

  val fsync :
    t ->
      Error.t

  val fdatasync :
    t ->
      Error.t

  val ftruncate :
    t -> int64 ->
      Error.t

  val copyfile :
    from:string -> to_:string -> Copy_flag.t ->
      Error.t

  (* DOC The offset should be optional, but current libuv doesn't seem to
     support that. *)
  val sendfile :
    to_:t -> from:t -> offset:int64 -> Unsigned.Size_t.t ->
      (Unsigned.Size_t.t, Error.t) Result.result

  val access :
    string -> Access_flag.t ->
      Error.t

  val chmod :
    string -> Mode.t ->
      Error.t

  val fchmod :
    t -> Mode.t ->
      Error.t

  val utime :
    string -> atime:float -> mtime:float ->
      Error.t

  val futime :
    t -> atime:float -> mtime:float ->
      Error.t

  val link :
    target:string -> link:string ->
      Error.t

  val symlink :
    target:string -> link:string -> Symlink_flag.t ->
      Error.t

  val readlink :
    string ->
      (string, Error.t) Result.result

  val realpath :
    string ->
      (string, Error.t) Result.result

  val chown :
    string -> uid:int -> gid:int ->
      Error.t

  val fchown :
    t -> uid:int -> gid:int ->
      Error.t

  val lchown :
    string -> uid:int -> gid:int ->
      Error.t
end

val get_osfhandle : t -> (Misc.Os_fd.t, Error.t) Result.result
val open_osfhandle : Misc.Os_fd.t -> (t, Error.t) Result.result

val to_int : t -> int
(* DOC This is here largely because the Process module is defined by libuv to
   expect ints. *)
