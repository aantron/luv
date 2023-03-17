module Types = Types_generated

(* We want to be able to call some of the libuv functions with the OCaml runtime
   lock released, in some circumstances. For that, we have Ctypes generate
   separate stubs that release the lock.

   However, releasing the lock is not possible for some kinds of arguments. So,
   we can't blindly generate lock-releasing and lock-retaining versions of each
   binding.

   Instead, we group the lock-releasing bindings in this module [Blocking]. *)
module Functions (F : Ctypes.FOREIGN) =
struct
  open Ctypes
  open F

  let error_code = int

  module Loop =
  struct
    let run =
      foreign "uv_run"
        (ptr Types.Loop.t @-> Types.Loop.Run_mode.t @-> returning bool)
  end

  (* See https://github.com/ocsigen/lwt/issues/230. *)
  module Pipe =
  struct
    let bind =
      foreign "uv_pipe_bind"
        (ptr Types.Pipe.t @-> string @-> returning error_code)
  end

  (* Synchronous (callback = NULL) calls to these functions are blocking, so we
     have to release the OCaml runtime lock. Technically, asychronous calls are
     non-blocking, and we don't have to release the lock. However, supporting
     both variants would take a bit of extra code to implement, so it's best to
     see if there is a need. For now, we release the runtime lock during the
     asychronous calls as well. *)
  module File =
  struct
    let t = int
    let uid = int
    let gid = int
    let request = Types.File.Request.t

    type trampoline = (Types.File.Request.t ptr -> unit) static_funptr

    let trampoline : trampoline typ =
      static_funptr
        Ctypes.(ptr request @-> returning void)

    let get_trampoline =
      foreign "luv_get_fs_trampoline"
        (void @-> returning trampoline)

    let get_null_callback =
      foreign "luv_null_fs_callback_pointer"
        (void @-> returning trampoline)

    let req_cleanup =
      foreign "uv_fs_req_cleanup"
        (ptr request @-> returning void)

    let close =
      foreign "uv_fs_close"
        (ptr Types.Loop.t @-> ptr request @-> t @-> trampoline @->
          returning error_code)

    let open_ =
      foreign "uv_fs_open"
        (ptr Types.Loop.t @->
         ptr request @->
         string @->
         int @->
         int @->
         trampoline @->
          returning error_code)

    let read =
      foreign "uv_fs_read"
        (ptr Types.Loop.t @->
         ptr request @->
         t @->
         ptr Types.Buf.t @->
         uint @->
         int64_t @->
         trampoline @->
          returning error_code)

    let write =
      foreign "uv_fs_write"
        (ptr Types.Loop.t @->
         ptr request @->
         t @->
         ptr Types.Buf.t @->
         uint @->
         int64_t @->
         trampoline @->
           returning error_code)

    let unlink =
      foreign "uv_fs_unlink"
        (ptr Types.Loop.t @-> ptr request @-> string @-> trampoline @->
          returning error_code)

    let mkdir =
      foreign "uv_fs_mkdir"
        (ptr Types.Loop.t @-> ptr request @-> string @-> int @-> trampoline @->
          returning error_code)

    let mkdtemp =
      foreign "uv_fs_mkdtemp"
        (ptr Types.Loop.t @-> ptr request @-> string @-> trampoline @->
          returning error_code)

    let mkstemp =
      foreign "uv_fs_mkstemp"
        (ptr Types.Loop.t @-> ptr request @-> string @-> trampoline @->
          returning error_code)

    let rmdir =
      foreign "uv_fs_rmdir"
        (ptr Types.Loop.t @-> ptr request @-> string @-> trampoline @->
          returning error_code)

    let opendir =
      foreign "uv_fs_opendir"
        (ptr Types.Loop.t @-> ptr request @-> string @-> trampoline @->
          returning error_code)

    let closedir =
      foreign "uv_fs_closedir"
        (ptr Types.Loop.t @->
         ptr request @->
         ptr Types.File.Dir.t @->
         trampoline @->
          returning error_code)

    let readdir =
      foreign "uv_fs_readdir"
        (ptr Types.Loop.t @->
         ptr request @->
         ptr Types.File.Dir.t @->
         trampoline @->
          returning error_code)

    let scandir =
      foreign "uv_fs_scandir"
        (ptr Types.Loop.t @-> ptr request @-> string @-> int @-> trampoline @->
          returning error_code)

    let scandir_next =
      foreign "uv_fs_scandir_next"
        (ptr request @-> ptr Types.File.Dirent.t @-> returning error_code)

    let stat =
      foreign "uv_fs_stat"
        (ptr Types.Loop.t @-> ptr request @-> string @-> trampoline @->
          returning error_code)

    let lstat =
      foreign "uv_fs_lstat"
        (ptr Types.Loop.t @-> ptr request @-> string @-> trampoline @->
          returning error_code)

    let fstat =
      foreign "uv_fs_fstat"
        (ptr Types.Loop.t @-> ptr request @-> t @-> trampoline @->
          returning error_code)

    let statfs =
      foreign "uv_fs_statfs"
        (ptr Types.Loop.t @-> ptr request @-> string @-> trampoline @->
          returning error_code)

    let rename =
      foreign "uv_fs_rename"
        (ptr Types.Loop.t @->
         ptr request @->
         string @->
         string @->
         trampoline @->
          returning error_code)

    let fsync =
      foreign "uv_fs_fsync"
        (ptr Types.Loop.t @-> ptr request @-> t @-> trampoline @->
          returning error_code)

    let fdatasync =
      foreign "uv_fs_fdatasync"
        (ptr Types.Loop.t @-> ptr request @-> t @-> trampoline @->
          returning error_code)

    let ftruncate =
      foreign "uv_fs_ftruncate"
        (ptr Types.Loop.t @-> ptr request @-> t @-> int64_t @-> trampoline @->
          returning error_code)

    let copyfile =
      foreign "uv_fs_copyfile"
        (ptr Types.Loop.t @->
         ptr request @->
         string @->
         string @->
         int @->
         trampoline @->
          returning error_code)

    let sendfile =
      foreign "uv_fs_sendfile"
        (ptr Types.Loop.t @->
         ptr request @->
         t @->
         t @->
         int64_t @->
         size_t @->
         trampoline @->
          returning error_code)

    let access =
      foreign "uv_fs_access"
        (ptr Types.Loop.t @-> ptr request @-> string @-> int @-> trampoline @->
          returning error_code)

    let chmod =
      foreign "uv_fs_chmod"
        (ptr Types.Loop.t @-> ptr request @-> string @-> int @-> trampoline @->
          returning error_code)

    let fchmod =
      foreign "uv_fs_fchmod"
        (ptr Types.Loop.t @-> ptr request @-> t @-> int @-> trampoline @->
          returning error_code)

    let utime =
      foreign "uv_fs_utime"
        (ptr Types.Loop.t @->
         ptr request @->
         string @->
         float @->
         float @->
         trampoline @->
          returning error_code)

    let futime =
      foreign "uv_fs_futime"
        (ptr Types.Loop.t @->
         ptr request @->
         t @->
         float @->
         float @->
         trampoline @->
          returning error_code)

    let lutime =
      foreign "uv_fs_lutime"
        (ptr Types.Loop.t @->
         ptr request @->
         string @->
         float @->
         float @->
         trampoline @->
          returning error_code)

    let link =
      foreign "uv_fs_link"
        (ptr Types.Loop.t @->
         ptr request @->
         string @->
         string @->
         trampoline @->
          returning error_code)

    let symlink =
      foreign "uv_fs_symlink"
        (ptr Types.Loop.t @->
         ptr request @->
         string @->
         string @->
         int @->
         trampoline @->
          returning error_code)

    let readlink =
      foreign "uv_fs_readlink"
        (ptr Types.Loop.t @-> ptr request @-> string @-> trampoline @->
          returning error_code)

    let realpath =
      foreign "uv_fs_realpath"
        (ptr Types.Loop.t @-> ptr request @-> string @-> trampoline @->
          returning error_code)

    let chown =
      foreign "uv_fs_chown"
        (ptr Types.Loop.t @->
         ptr request @->
         string @->
         uid @->
         gid @->
         trampoline @->
          returning error_code)

    let fchown =
      foreign "uv_fs_fchown"
        (ptr Types.Loop.t @->
         ptr request @->
         t @->
         uid @->
         gid @->
         trampoline @->
          returning error_code)

    let lchown =
      foreign "uv_fs_lchown"
        (ptr Types.Loop.t @->
         ptr request @->
         string @->
         uid @->
         gid @->
         trampoline @->
          returning error_code)

    let get_result =
      foreign "uv_fs_get_result"
        (ptr request @-> returning PosixTypes.ssize_t)

    let get_ptr =
      foreign "uv_fs_get_ptr"
        (ptr request @-> returning (ptr void))

    let get_ptr_as_string =
      foreign "uv_fs_get_ptr"
        (ptr request @-> returning string)

    let get_path =
      foreign "luv_fs_get_path"
        (ptr request @-> returning string)

    let get_statbuf =
      foreign "uv_fs_get_statbuf"
        (ptr request @-> returning (ptr Types.File.Stat.t))
  end

  module Thread =
  struct
    let join =
      foreign "uv_thread_join"
        (ptr Types.Thread.t @-> returning error_code)
  end

  module Mutex =
  struct
    let lock =
      foreign "uv_mutex_lock"
        (ptr Types.Mutex.t @-> returning void)
  end

  module Rwlock =
  struct
    let rdlock =
      foreign "uv_rwlock_rdlock"
        (ptr Types.Rwlock.t @-> returning void)

    let wrlock =
      foreign "uv_rwlock_wrlock"
        (ptr Types.Rwlock.t @-> returning void)
  end

  module Semaphore =
  struct
    let wait =
      foreign "uv_sem_wait"
        (ptr Types.Semaphore.t @-> returning void)
  end

  module Condition =
  struct
    let wait =
      foreign "uv_cond_wait"
        (ptr Types.Condition.t @-> ptr Types.Mutex.t @-> returning void)

    let timedwait =
      foreign "uv_cond_timedwait"
        (ptr Types.Condition.t @-> ptr Types.Mutex.t @-> uint64_t @->
          returning error_code)
  end

  module Barrier =
  struct
    let wait =
      foreign "uv_barrier_wait"
        (ptr Types.Barrier.t @-> returning bool)
  end

  module Time =
  struct
    let sleep =
      foreign "uv_sleep"
        (int @-> returning void)
  end

  module Random =
  struct
    let request = Types.Random.Request.t

    let trampoline =
      static_funptr
        Ctypes.(ptr request @-> error_code @-> ptr void @-> size_t @->
          returning void)

    let random =
      foreign "uv_random"
        (ptr Types.Loop.t @->
         ptr request @->
         ptr char @->
         size_t @->
         uint @->
         trampoline @->
          returning error_code)
  end
end
