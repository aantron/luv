(* Everything is in one file to cut down on Dune boilerplate, as it would grow
   proportionally in the number of files the bindings are spread over.
   https://github.com/ocaml/dune/issues/135. *)

(* DOC Tell users they may need to scan strings for internal null terminators
   and fail if found? *)

module Types = Luv_c_types

(* We want to be able to call some of the libuv functions with the OCaml runtime
   lock released, in some circumstances. For that, we have Ctypes generate
   separate stubs that release the lock.

   However, releasing the lock is not possible for some kinds of arguments. So,
   we can't blindly generate lock-releasing and lock-retaining versions of each
   binding.

   Instead, we group the lock-releasing bindings in this module [Blocking]. *)
module Blocking (F : Ctypes.FOREIGN) =
struct
  let error_code = Types.Error.t
  open Ctypes
  open F

  module Loop =
  struct
    let run =
      foreign "uv_run"
        (ptr Types.Loop.t @-> int @-> returning bool)
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
      foreign "luv_address_of_fs_trampoline"
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

    let rmdir =
      foreign "uv_fs_rmdir"
        (ptr Types.Loop.t @-> ptr request @-> string @-> trampoline @->
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
        (ptr request @-> returning string)

    let get_path =
      foreign "luv_fs_get_path"
        (ptr request @-> returning string)

    let get_statbuf =
      foreign "uv_fs_get_statbuf"
        (ptr request @-> returning (ptr Types.File.Stat.t))
  end
end

module Descriptions (F : Ctypes.FOREIGN) =
struct
  let error_code = Types.Error.t
  open Ctypes
  open F

  module Error =
  struct
    let strerror =
      foreign "luv_strerror"
        (error_code @-> returning string)

    let err_name_r =
      foreign "uv_err_name_r"
        (error_code @-> ocaml_bytes @-> int @-> returning void)

    let translate_sys_error =
      foreign "uv_translate_sys_error"
        (int @-> returning error_code)
  end

  module Version =
  struct
    let suffix =
      foreign "luv_version_suffix"
        (void @-> returning string)

    let version =
      foreign "uv_version"
        (void @-> returning int)

    let string =
      foreign "luv_version_string"
        (void @-> returning string)
  end

  module Loop =
  struct
    let t = Types.Loop.t

    let init =
      foreign "uv_loop_init"
        (ptr t @-> returning error_code)

    let configure =
      foreign "uv_loop_configure"
        (ptr t @-> int @-> int @-> returning error_code)

    let close =
      foreign "uv_loop_close"
        (ptr t @-> returning error_code)

    let default =
      foreign "uv_default_loop"
        (void @-> returning (ptr t))

    let alive =
      foreign "uv_loop_alive"
        (ptr t @-> returning bool)

    let stop =
      foreign "uv_stop"
        (ptr t @-> returning void)

    let size =
      foreign "uv_loop_size"
        (void @-> returning size_t)

    let backend_fd =
      foreign "uv_backend_fd"
        (ptr t @-> returning int)

    let backend_timeout =
      foreign "uv_backend_timeout"
        (ptr t @-> returning int)

    let now =
      foreign "uv_now"
        (ptr t @-> returning uint64_t)

    let update_time =
      foreign "uv_update_time"
        (ptr t @-> returning void)

    let fork =
      foreign "uv_loop_fork"
        (ptr t @-> returning error_code)

    let get_data =
      foreign "uv_loop_get_data"
        (ptr t @-> returning (ptr void))

    let set_data =
      foreign "uv_loop_set_data"
        (ptr t @-> ptr void @-> returning void)
  end

  module Handle =
  struct
    let t = Types.Handle.t

    let close_trampoline =
      static_funptr
        Ctypes.(ptr t @-> returning void)

    let alloc_trampoline =
      static_funptr
        Ctypes.(ptr t @-> size_t @-> ptr Types.Buf.t @-> returning void)

    let get_close_trampoline =
      foreign "luv_address_of_close_trampoline"
        (void @-> returning close_trampoline)

    let get_alloc_trampoline =
      foreign "luv_address_of_alloc_trampoline"
        (void @-> returning alloc_trampoline)

    let is_active =
      foreign "uv_is_active"
        (ptr t @-> returning bool)

    let is_closing =
      foreign "uv_is_closing"
        (ptr t @-> returning bool)

    let close =
      foreign "uv_close"
        (ptr t @-> close_trampoline @-> returning void)

    let ref =
      foreign "uv_ref"
        (ptr t @-> returning void)

    let unref =
      foreign "uv_unref"
        (ptr t @-> returning void)

    let has_ref =
      foreign "uv_has_ref"
        (ptr t @-> returning bool)

    (* TODO ??? *)
    (* let send_buffer_size =
      foreign "uv_send_buffer_size" (ptr t @-> ptr int @-> returning error_code)
    let recv_buffer_size =
      foreign "uv_recv_buffer_size" (ptr t @-> ptr int @-> returning error_code)
       *)
    (* let walk =
      foreign "uv_walk"
        (ptr Loop.t @->
         funptr Ctypes.(ptr t @-> ptr void @-> returning void) @->
         ptr void @->
          returning void) *)

    let fileno =
      foreign "uv_fileno"
        (ptr t @-> ptr Types.Os_fd.t @-> returning error_code)

    let get_loop =
      foreign "uv_handle_get_loop"
        (ptr t @-> returning (ptr Loop.t))

    let get_data =
      foreign "uv_handle_get_data"
        (ptr t @-> returning (ptr void))

    let set_data =
      foreign "uv_handle_set_data"
        (ptr t @-> ptr void @-> returning void)
  end

  module Request =
  struct
    let t = Types.Request.t

    let cancel =
      foreign "uv_cancel"
        (ptr t @-> returning error_code)

    let get_data =
      foreign "uv_req_get_data"
        (ptr t @-> returning (ptr void))

    let set_data =
      foreign "uv_req_set_data"
        (ptr t @-> ptr void @-> returning void)
  end

  module Timer =
  struct
    let t = Types.Timer.t

    let trampoline =
      static_funptr
        Ctypes.(ptr t @-> returning void)

    let get_trampoline =
      foreign "luv_address_of_timer_trampoline"
        (void @-> returning trampoline)

    let init =
      foreign "uv_timer_init"
        (ptr Loop.t @-> ptr t @-> returning error_code)

    let start =
      foreign "uv_timer_start"
        (ptr t @-> trampoline @-> uint64_t @-> uint64_t @->
          returning error_code)

    let stop =
      foreign "uv_timer_stop"
        (ptr t @-> returning error_code)

    let again =
      foreign "uv_timer_again"
        (ptr t @-> returning error_code)

    let set_repeat =
      foreign "uv_timer_set_repeat"
        (ptr t @-> uint64_t @-> returning void)

    let get_repeat =
      foreign "uv_timer_get_repeat"
        (ptr t @-> returning uint64_t)
  end

  module Prepare =
  struct
    let t = Types.Prepare.t

    let trampoline =
      static_funptr
        Ctypes.(ptr t @-> returning void)

    let get_trampoline =
      foreign "luv_address_of_prepare_trampoline"
        (void @-> returning trampoline)

    let init =
      foreign "uv_prepare_init"
        (ptr Loop.t @-> ptr t @-> returning error_code)

    let start =
      foreign "uv_prepare_start"
        (ptr t @-> trampoline @-> returning error_code)

    let stop =
      foreign "uv_prepare_stop"
        (ptr t @-> returning error_code)
  end

  module Check =
  struct
    let t = Types.Check.t

    let trampoline =
      static_funptr
        Ctypes.(ptr t @-> returning void)

    let get_trampoline =
      foreign "luv_address_of_check_trampoline"
        (void @-> returning trampoline)

    let init =
      foreign "uv_check_init"
        (ptr Loop.t @-> ptr t @-> returning error_code)

    let start =
      foreign "uv_check_start"
        (ptr t @-> trampoline @-> returning error_code)

    let stop =
      foreign "uv_check_stop"
        (ptr t @-> returning error_code)
  end

  module Idle =
  struct
    let t = Types.Idle.t

    let trampoline =
      static_funptr
        Ctypes.(ptr t @-> returning void)

    let get_trampoline =
      foreign "luv_address_of_idle_trampoline"
        (void @-> returning trampoline)

    let init =
      foreign "uv_idle_init"
        (ptr Loop.t @-> ptr t @-> returning error_code)

    let start =
      foreign "uv_idle_start"
        (ptr t @-> trampoline @-> returning error_code)

    let stop =
      foreign "uv_idle_stop"
        (ptr t @-> returning error_code)
  end

  module Async =
  struct
    let t = Types.Async.t

    let trampoline =
      static_funptr
        Ctypes.(ptr t @-> returning void)

    let get_trampoline =
      foreign "luv_address_of_async_trampoline"
        (void @-> returning trampoline)

    let init =
      foreign "uv_async_init"
        (ptr Loop.t @-> ptr t @-> trampoline @-> returning error_code)

    let send =
      foreign "uv_async_send"
        (ptr t @-> returning error_code)
  end

  (* TODO Finish after there is a way of getting an fd? *)
  module Poll =
  struct
    let t = Types.Poll.t

    let trampoline =
      static_funptr
        Ctypes.(ptr t @-> int @-> int @-> returning void)

    let get_trampoline =
      foreign "luv_address_of_poll_trampoline"
        (void @-> returning trampoline)

    let init =
      foreign "uv_poll_init"
        (ptr Loop.t @-> ptr t @-> int @-> returning error_code)

    (* TODO Bind uv_os_sock_t, and create a custom stub. *)
    (* let init_socket =
      foreign "uv_poll_init_socket"
        (ptr Loop.t @-> ptr t @-> Types.Misc.Os_fd.t @-> returning error_code) *)

    let start =
      foreign "uv_poll_start"
        (ptr t @-> int @-> trampoline @-> returning error_code)

    let stop =
      foreign "uv_poll_stop"
        (ptr t @-> returning error_code)
  end

  module Signal =
  struct
    let t = Types.Signal.t

    let trampoline =
      static_funptr
        Ctypes.(ptr t @-> int @-> returning void)

    let get_trampoline =
      foreign "luv_address_of_signal_trampoline"
        (void @-> returning trampoline)

    let init =
      foreign "uv_signal_init"
        (ptr Loop.t @-> ptr t @-> returning error_code)

    let start =
      foreign "uv_signal_start"
        (ptr t @-> trampoline @-> int @-> returning error_code)

    let start_oneshot =
      foreign "uv_signal_start_oneshot"
        (ptr t @-> trampoline @-> int @-> returning error_code)

    let stop =
      foreign "uv_signal_stop"
        (ptr t @-> returning error_code)
  end

  module Stream =
  struct
    module Connect_request =
    struct
      let trampoline =
        static_funptr
          Ctypes.(ptr Types.Stream.Connect_request.t @-> error_code @->
            returning void)

      let get_trampoline =
        foreign "luv_address_of_connect_trampoline"
          (void @-> returning trampoline)
    end

    module Shutdown_request =
    struct
      let trampoline =
        static_funptr
          Ctypes.(ptr Types.Stream.Shutdown_request.t @-> error_code @->
            returning void)

      let get_trampoline =
        foreign "luv_address_of_shutdown_trampoline"
          (void @-> returning trampoline)
    end

    module Write_request =
    struct
      let trampoline =
        static_funptr
          Ctypes.(ptr Types.Stream.Write_request.t @-> error_code @->
            returning void)

      let get_trampoline =
        foreign "luv_address_of_write_trampoline"
          (void @-> returning trampoline)
    end

    let t = Types.Stream.t

    let connection_trampoline =
      static_funptr
        Ctypes.(ptr t @-> error_code @-> returning void)

    let read_trampoline =
      static_funptr
        Ctypes.(ptr t @-> PosixTypes.ssize_t @-> ptr Types.Buf.t @->
          returning void)

    let get_connection_trampoline =
      foreign "luv_address_of_connection_trampoline"
        (void @-> returning connection_trampoline)

    let get_read_trampoline =
      foreign "luv_address_of_read_trampoline"
        (void @-> returning read_trampoline)

    let shutdown =
      foreign "uv_shutdown"
        (ptr Types.Stream.Shutdown_request.t @->
         ptr t @->
         Shutdown_request.trampoline @->
          returning error_code)

    let listen =
      foreign "uv_listen"
        (ptr t @-> int @-> connection_trampoline @-> returning error_code)

    let accept =
      foreign "uv_accept"
        (ptr t @-> ptr t @-> returning error_code)

    let read_start =
      foreign "luv_read_start"
        (ptr t @-> Handle.alloc_trampoline @-> read_trampoline @->
          returning error_code)

    let read_stop =
      foreign "uv_read_stop"
        (ptr t @-> returning error_code)

    let write2 =
      foreign "uv_write2"
        (ptr Types.Stream.Write_request.t @->
         ptr t @->
         ptr Types.Buf.t @->
         uint @->
         ptr t @->
         Write_request.trampoline @->
          returning error_code)

    let try_write =
      foreign "uv_try_write"
        (ptr t @-> ptr Types.Buf.t @-> uint @-> returning error_code)

    let is_readable =
      foreign "uv_is_readable"
        (ptr t @-> returning bool)

    let is_writable =
      foreign "uv_is_writable"
        (ptr t @-> returning bool)

    let set_blocking =
      foreign "uv_stream_set_blocking"
        (ptr t @-> bool @-> returning error_code)

    let get_write_queue_size =
      foreign "uv_stream_get_write_queue_size"
        (ptr t @-> returning size_t)
  end

  module TCP =
  struct
    let t = Types.TCP.t

    let init =
      foreign "uv_tcp_init"
        (ptr Loop.t @-> ptr t @-> returning error_code)

    let init_ex =
      foreign "uv_tcp_init_ex"
        (ptr Loop.t @-> ptr t @-> uint @-> returning error_code)

    let nodelay =
      foreign "uv_tcp_nodelay"
        (ptr t @-> bool @-> returning error_code)

    let keepalive =
      foreign "uv_tcp_keepalive"
        (ptr t @-> bool @-> int @-> returning error_code)

    let simultaneous_accepts =
      foreign "uv_tcp_simultaneous_accepts"
        (ptr t @-> bool @-> returning error_code)

    let bind =
      foreign "uv_tcp_bind"
        (ptr t @-> ptr Types.Sockaddr.t @-> int @-> returning error_code)

    let getsockname =
      foreign "uv_tcp_getsockname"
        (ptr t @-> ptr Types.Sockaddr.t @-> ptr int @-> returning error_code)

    let getpeername =
      foreign "uv_tcp_getpeername"
        (ptr t @-> ptr Types.Sockaddr.t @-> ptr int @-> returning error_code)

    let connect =
      foreign "uv_tcp_connect"
        (ptr Types.Stream.Connect_request.t @->
         ptr t @->
         ptr Types.Sockaddr.t @->
         Stream.Connect_request.trampoline @->
          returning error_code)
  end

  module Pipe =
  struct
    let t = Types.Pipe.t

    let init =
      foreign "uv_pipe_init"
        (ptr Loop.t @-> ptr t @-> bool @-> returning error_code)

    let open_ =
      foreign "uv_pipe_open"
        (ptr t @-> int @-> returning error_code)

    let connect =
      foreign "uv_pipe_connect"
        (ptr Types.Stream.Connect_request.t @->
         ptr t @->
         ocaml_string @->
         Stream.Connect_request.trampoline @->
          returning void)

    let getsockname =
      foreign "uv_pipe_getsockname"
        (ptr t @-> ocaml_bytes @-> ptr size_t @-> returning error_code)

    let getpeername =
      foreign "uv_pipe_getpeername"
        (ptr t @-> ocaml_bytes @-> ptr size_t @-> returning error_code)

    let pending_instances =
      foreign "uv_pipe_pending_instances"
        (ptr t @-> int @-> returning void)

    let pending_count =
      foreign "uv_pipe_pending_count"
        (ptr t @-> returning int)

    let pending_type =
      foreign "uv_pipe_pending_type"
        (ptr t @-> returning int)

    let chmod =
      foreign "uv_pipe_chmod"
        (ptr t @-> int @-> returning error_code)
  end

  module Process =
  struct
    let t = Types.Process.t

    let exit_cb =
      static_funptr
        Ctypes.(ptr t @-> int64_t @-> int @-> returning void)

    let get_trampoline =
      foreign "luv_address_of_exit_trampoline"
        (void @-> returning exit_cb)

    let get_null_callback =
      foreign "luv_null_exit_trampoline"
        (void @-> returning exit_cb)

    let disable_stdio_inheritance =
      foreign "uv_disable_stdio_inheritance"
        (void @-> returning void)

    let spawn =
      foreign "luv_spawn"
        (ptr Loop.t @->
         ptr t @->
         exit_cb @->
         ocaml_string @->
         ptr string @->
         int @->
         ptr string @->
         int @->
         bool @->
         ocaml_string @->
         bool @->
         int @->
         int @->
         ptr Types.Process.Redirection.t @->
         int @->
         int @->
          returning error_code)

    let process_kill =
      foreign "uv_process_kill"
        (ptr t @-> int @-> returning error_code)

    let kill =
      foreign "uv_kill"
        (int @-> int @-> returning error_code)

    let get_pid =
      foreign "uv_process_get_pid"
        (ptr t @-> returning int)
  end

  module Os_fd =
  struct
    let get_osfhandle =
      foreign "uv_get_osfhandle"
        (int @-> returning Types.Os_fd.t)

    let open_osfhandle =
      foreign "uv_open_osfhandle"
        (Types.Os_fd.t @-> returning int)

    let is_invalid_handle_value =
      foreign "luv_is_invalid_handle_value"
        (Types.Os_fd.t @-> returning bool)
  end

  module Bigstring =
  struct
    let memcpy_to_bytes =
      foreign "memcpy"
        (ocaml_bytes @-> ptr char @-> int @-> returning void)

    let memcpy_from_bytes =
      foreign "memcpy"
        (ptr char @-> ocaml_bytes @-> int @-> returning void)
  end
end
