(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Types = Types_generated

module Functions(F : Ctypes.FOREIGN) = struct
  (* We want to be able to call some of the libuv functions with the OCaml
     runtime lock released, in some circumstances. For that, we have Ctypes
     generate separate stubs that release the lock.

     The functions in this file are called with the runtime lock HELD. *)

  open Ctypes
  open F

  let error_code = int

  module Error =
  struct
    let strerror_r =
      foreign "uv_strerror_r"
        (error_code @-> ocaml_bytes @-> int @-> returning void)

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

    let library_shutdown =
      foreign "uv_library_shutdown"
        (void @-> returning void)
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
      foreign "luv_get_close_trampoline"
        (void @-> returning close_trampoline)

    let get_alloc_trampoline =
      foreign "luv_get_alloc_trampoline"
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

    let send_buffer_size =
      foreign "uv_send_buffer_size"
        (ptr t @-> ptr int @-> returning error_code)

    let recv_buffer_size =
      foreign "uv_recv_buffer_size"
        (ptr t @-> ptr int @-> returning error_code)

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
      foreign "luv_get_timer_trampoline"
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

    let get_due_in =
      foreign "uv_timer_get_due_in"
        (ptr t @-> returning uint64_t)
  end

  module Prepare =
  struct
    let t = Types.Prepare.t

    let trampoline =
      static_funptr
        Ctypes.(ptr t @-> returning void)

    let get_trampoline =
      foreign "luv_get_prepare_trampoline"
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
      foreign "luv_get_check_trampoline"
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
      foreign "luv_get_idle_trampoline"
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
      foreign "luv_get_async_trampoline"
        (void @-> returning trampoline)

    let init =
      foreign "uv_async_init"
        (ptr Loop.t @-> ptr t @-> trampoline @-> returning error_code)

    let send =
      foreign "uv_async_send"
        (ptr t @-> returning error_code)
  end

  module Poll =
  struct
    let t = Types.Poll.t

    let trampoline =
      static_funptr
        Ctypes.(ptr t @-> int @-> int @-> returning void)

    let get_trampoline =
      foreign "luv_get_poll_trampoline"
        (void @-> returning trampoline)

    let init =
      foreign "uv_poll_init"
        (ptr Loop.t @-> ptr t @-> int @-> returning error_code)

    let init_socket =
      foreign "uv_poll_init_socket"
        (ptr Loop.t @-> ptr t @-> Types.Os_socket.t @-> returning error_code)

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
      foreign "luv_get_signal_trampoline"
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
        foreign "luv_get_connect_trampoline"
          (void @-> returning trampoline)
    end

    module Shutdown_request =
    struct
      let trampoline =
        static_funptr
          Ctypes.(ptr Types.Stream.Shutdown_request.t @-> error_code @->
                  returning void)

      let get_trampoline =
        foreign "luv_get_shutdown_trampoline"
          (void @-> returning trampoline)
    end

    module Write_request =
    struct
      let trampoline =
        static_funptr
          Ctypes.(ptr Types.Stream.Write_request.t @-> error_code @->
                  returning void)

      let get_trampoline =
        foreign "luv_get_write_trampoline"
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
      foreign "luv_get_connection_trampoline"
        (void @-> returning connection_trampoline)

    let get_read_trampoline =
      foreign "luv_get_read_trampoline"
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

    let open_ =
      foreign "uv_tcp_open"
        (ptr t @-> Types.Os_socket.t @-> returning error_code)

    let socketpair =
      foreign "uv_socketpair"
        (int @-> int @-> ptr Types.Os_socket.t @-> int @-> int @->
         returning error_code)

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

    let close_reset =
      foreign "uv_tcp_close_reset"
        (ptr t @-> Handle.close_trampoline @-> returning error_code)
  end

  module Pipe =
  struct
    let t = Types.Pipe.t

    let init =
      foreign "uv_pipe_init"
        (ptr Loop.t @-> ptr t @-> bool @-> returning error_code)

    let pipe =
      foreign "uv_pipe"
        (ptr int @-> int @-> int @-> returning error_code)

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

  module TTY =
  struct
    let t = Types.TTY.t

    let init =
      foreign "uv_tty_init"
        (ptr Loop.t @-> ptr t @-> Types.File.t @-> int @-> returning error_code)

    let set_mode =
      foreign "uv_tty_set_mode"
        (ptr t @-> Types.TTY.Mode.t @-> returning error_code)

    let reset_mode =
      foreign "uv_tty_reset_mode"
        (void @-> returning error_code)

    let get_winsize =
      foreign "uv_tty_get_winsize"
        (ptr t @-> ptr int @-> ptr int @-> returning error_code)

    let set_vterm_state =
      foreign "uv_tty_set_vterm_state"
        (Types.TTY.Vterm_state.t @-> returning void)

    let get_vterm_state =
      foreign "uv_tty_get_vterm_state"
        (ptr Types.TTY.Vterm_state.t @-> returning error_code)
  end

  module UDP =
  struct
    let t = Types.UDP.t

    let init =
      foreign "uv_udp_init"
        (ptr Loop.t @-> ptr t @-> returning error_code)

    let init_ex =
      foreign "uv_udp_init_ex"
        (ptr Loop.t @-> ptr t @-> uint @-> returning error_code)

    let open_ =
      foreign "uv_udp_open"
        (ptr t @-> Types.Os_socket.t @-> returning error_code)

    let bind =
      foreign "uv_udp_bind"
        (ptr t @-> ptr Types.Sockaddr.t @-> int @-> returning error_code)

    let connect =
      foreign "uv_udp_connect"
        (ptr t @-> ptr Types.Sockaddr.t @-> returning error_code)

    let getpeername =
      foreign "uv_udp_getpeername"
        (ptr t @-> ptr Types.Sockaddr.t @-> ptr int @-> returning error_code)

    let getsockname =
      foreign "uv_udp_getsockname"
        (ptr t @-> ptr Types.Sockaddr.t @-> ptr int @-> returning error_code)

    let set_membership =
      foreign "uv_udp_set_membership"
        (ptr t @-> ocaml_string @-> ocaml_string @-> Types.UDP.Membership.t @->
         returning error_code)

    let set_source_membership =
      foreign "uv_udp_set_source_membership"
        (ptr t @->
         ocaml_string @->
         ocaml_string @->
         ocaml_string @->
         Types.UDP.Membership.t @->
         returning error_code)

    let set_multicast_loop =
      foreign "uv_udp_set_multicast_loop"
        (ptr t @-> bool @-> returning error_code)

    let set_multicast_ttl =
      foreign "uv_udp_set_multicast_ttl"
        (ptr t @-> int @-> returning error_code)

    let set_multicast_interface =
      foreign "uv_udp_set_multicast_interface"
        (ptr t @-> ocaml_string @-> returning error_code)

    let set_broadcast =
      foreign "uv_udp_set_broadcast"
        (ptr t @-> bool @-> returning error_code)

    let set_ttl =
      foreign "uv_udp_set_ttl"
        (ptr t @-> int @-> returning error_code)

    module Send_request =
    struct
      let trampoline =
        static_funptr
          Ctypes.(ptr Types.UDP.Send_request.t @-> error_code @->
                  returning void)

      let get_trampoline =
        foreign "luv_get_send_trampoline"
          (void @-> returning trampoline)
    end

    let send =
      foreign "uv_udp_send"
        (ptr Types.UDP.Send_request.t @->
         ptr t @->
         ptr Types.Buf.t @->
         uint @->
         ptr Types.Sockaddr.t @->
         Send_request.trampoline @->
         returning error_code)

    let try_send =
      foreign "uv_udp_try_send"
        (ptr t @-> ptr Types.Buf.t @-> uint @-> ptr Types.Sockaddr.t @->
         returning error_code)

    let recv_trampoline =
      static_funptr
        Ctypes.(
          ptr t @->
          PosixTypes.ssize_t @->
          ptr Types.Buf.t @->
          ptr Types.Sockaddr.t @->
          uint @->
          returning void)

    let get_recv_trampoline =
      foreign "luv_get_recv_trampoline"
        (void @-> returning recv_trampoline)

    let recv_start =
      foreign "luv_udp_recv_start"
        (ptr t @-> Handle.alloc_trampoline @-> recv_trampoline @->
         returning error_code)

    let recv_stop =
      foreign "uv_udp_recv_stop"
        (ptr t @-> returning error_code)

    let using_recvmmsg =
      foreign "uv_udp_using_recvmmsg"
        (ptr t @-> returning bool)

    let get_send_queue_size =
      foreign "uv_udp_get_send_queue_size"
        (ptr t @-> returning size_t)

    let get_send_queue_count =
      foreign "uv_udp_get_send_queue_count"
        (ptr t @-> returning size_t)
  end

  module Process =
  struct
    let t = Types.Process.t

    let exit_cb =
      static_funptr
        Ctypes.(ptr t @-> int64_t @-> int @-> returning void)

    let get_trampoline =
      foreign "luv_get_exit_trampoline"
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
         ptr char @->
         ptr (ptr char) @->
         int @->
         ptr (ptr char) @->
         int @->
         bool @->
         ptr char @->
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

  module FS_event =
  struct
    let t = Types.FS_event.t

    let trampoline =
      static_funptr
        Ctypes.(ptr t @-> ptr char @-> int @-> error_code @-> returning void)

    let get_trampoline =
      foreign "luv_get_fs_event_trampoline"
        (void @-> returning trampoline)

    let init =
      foreign "uv_fs_event_init"
        (ptr Loop.t @-> ptr t @-> returning error_code)

    let start =
      foreign "luv_fs_event_start"
        (ptr t @-> trampoline @-> ocaml_string @-> int @-> returning error_code)

    let stop =
      foreign "uv_fs_event_stop"
        (ptr t @-> returning error_code)
  end

  module FS_poll =
  struct
    let t = Types.FS_poll.t

    let trampoline =
      static_funptr
        Ctypes.(
          ptr t @->
          error_code @->
          ptr Types.File.Stat.t @->
          ptr Types.File.Stat.t @->
          returning void)

    let get_trampoline =
      foreign "luv_get_fs_poll_trampoline"
        (void @-> returning trampoline)

    let init =
      foreign "uv_fs_poll_init"
        (ptr Loop.t @-> ptr t @-> returning error_code)

    let start =
      foreign "luv_fs_poll_start"
        (ptr t @-> trampoline @-> ocaml_string @-> int @-> returning error_code)

    let stop =
      foreign "uv_fs_poll_stop"
        (ptr t @-> returning error_code)
  end

  module DNS =
  struct
    module Addr_info =
    struct
      let t = Types.DNS.Addr_info.Request.t
      let addrinfo = Types.DNS.Addr_info.t

      let trampoline =
        static_funptr
          Ctypes.(ptr t @-> error_code @-> ptr addrinfo @-> returning void)

      let get_trampoline =
        foreign "luv_get_getaddrinfo_trampoline"
          (void @-> returning trampoline)

      let getaddrinfo =
        foreign "uv_getaddrinfo"
          (ptr Loop.t @->
           ptr t @->
           trampoline @->
           string_opt @->
           string_opt @->
           ptr addrinfo @->
           returning error_code)

      let free =
        foreign "uv_freeaddrinfo"
          (ptr addrinfo @-> returning void)
    end

    module Name_info =
    struct
      let t = Types.DNS.Name_info.t

      let trampoline =
        static_funptr
          Ctypes.(ptr t @-> error_code @-> string @-> string @-> returning void)

      let get_trampoline =
        foreign "luv_get_getnameinfo_trampoline"
          (void @-> returning trampoline)

      let getnameinfo =
        foreign "luv_getnameinfo"
          (ptr Loop.t @->
           ptr t @->
           trampoline @->
           ptr Types.Sockaddr.t @->
           int @->
           returning error_code)
    end
  end

  module DLL =
  struct
    let t = Types.DLL.t

    let open_ =
      foreign "uv_dlopen"
        (ocaml_string @-> ptr t @-> returning bool)

    let close =
      foreign "uv_dlclose"
        (ptr t @-> returning void)

    let sym =
      foreign "uv_dlsym"
        (ptr t @-> ocaml_string @-> ptr (ptr void) @-> returning bool)

    let error =
      foreign "luv_dlerror"
        (ptr t @-> returning string)
  end

  module Os_fd =
  struct
    let get_osfhandle =
      foreign "uv_get_osfhandle"
        (int @-> returning Types.Os_fd.t)

    let open_osfhandle =
      foreign "uv_open_osfhandle"
        (Types.Os_fd.t @-> returning int)
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

  module Work =
  struct
    let t = Types.Work.t

    let work_trampoline =
      static_funptr
        Ctypes.(ptr t @-> returning void)

    let after_work_trampoline =
      static_funptr
        Ctypes.(ptr t @-> int @-> returning void)

    let get_work_trampoline =
      foreign "luv_get_work_trampoline"
        (void @-> returning work_trampoline)

    let get_after_work_trampoline =
      foreign "luv_get_after_work_trampoline"
        (void @-> returning after_work_trampoline)

    let get_c_work_trampoline =
      foreign "luv_get_c_work_trampoline"
        (void @-> returning work_trampoline)

    let get_after_c_work_trampoline =
      foreign "luv_get_after_c_work_trampoline"
        (void @-> returning after_work_trampoline)

    let add_c_function_and_argument =
      foreign "luv_add_c_function_and_argument"
        (ptr t @-> nativeint @-> nativeint @-> returning bool)

    let queue =
      foreign "uv_queue_work"
        (ptr Loop.t @-> ptr t @-> work_trampoline @-> after_work_trampoline @->
         returning error_code)
  end

  module Thread =
  struct
    let t = Types.Thread.t
    let options = Types.Thread.Options.t

    let trampoline =
      static_funptr
        Ctypes.(ptr void @-> returning void)

    let get_trampoline =
      foreign "luv_get_thread_trampoline"
        (void @-> returning trampoline)

    let create =
      foreign "uv_thread_create_ex"
        (ptr t @-> ptr options @-> trampoline @-> ptr void @->
         returning error_code)

    let create_c =
      foreign "luv_thread_create_c"
        (ptr t @-> ptr options @-> nativeint @-> nativeint @->
         returning error_code)

    let self =
      foreign "uv_thread_self"
        (void @-> returning t)

    let equal =
      foreign "uv_thread_equal"
        (ptr t @-> ptr t @-> returning bool)
  end

  module TLS =
  struct
    let t = Types.TLS.t

    let create =
      foreign "uv_key_create"
        (ptr t @-> returning error_code)

    let delete =
      foreign "uv_key_delete"
        (ptr t @-> returning void)

    let get =
      foreign "uv_key_get"
        (ptr t @-> returning (ptr void))

    let set =
      foreign "uv_key_set"
        (ptr t @-> ptr void @-> returning void)
  end

  module Once =
  struct
    let t = Types.Once.t

    let trampoline =
      static_funptr
        Ctypes.(void @-> returning void)

    let get_trampoline =
      foreign "luv_get_once_trampoline"
        (void @-> returning trampoline)

    let init =
      foreign "luv_once_init"
        (ptr t @-> returning error_code)

    let once =
      foreign "uv_once"
        (ptr t @-> trampoline @-> returning void)
  end

  module Mutex =
  struct
    let t = Types.Mutex.t

    let init =
      foreign "uv_mutex_init"
        (ptr t @-> returning error_code)

    let init_recursive =
      foreign "uv_mutex_init_recursive"
        (ptr t @-> returning error_code)

    let destroy =
      foreign "uv_mutex_destroy"
        (ptr t @-> returning void)

    let trylock =
      foreign "uv_mutex_trylock"
        (ptr t @-> returning error_code)

    let unlock =
      foreign "uv_mutex_unlock"
        (ptr t @-> returning void)
  end

  module Rwlock =
  struct
    let t = Types.Rwlock.t

    let init =
      foreign "uv_rwlock_init"
        (ptr t @-> returning error_code)

    let destroy =
      foreign "uv_rwlock_destroy"
        (ptr t @-> returning void)

    let tryrdlock =
      foreign "uv_rwlock_tryrdlock"
        (ptr t @-> returning error_code)

    let rdunlock =
      foreign "uv_rwlock_rdunlock"
        (ptr t @-> returning void)

    let trywrlock =
      foreign "uv_rwlock_trywrlock"
        (ptr t @-> returning error_code)

    let wrunlock =
      foreign "uv_rwlock_wrunlock"
        (ptr t @-> returning void)
  end

  module Semaphore =
  struct
    let t = Types.Semaphore.t

    let init =
      foreign "uv_sem_init"
        (ptr t @-> uint @-> returning error_code)

    let destroy =
      foreign "uv_sem_destroy"
        (ptr t @-> returning void)

    let post =
      foreign "uv_sem_post"
        (ptr t @-> returning void)

    let trywait =
      foreign "uv_sem_trywait"
        (ptr t @-> returning error_code)
  end

  module Condition =
  struct
    let t = Types.Condition.t

    let init =
      foreign "uv_cond_init"
        (ptr t @-> returning error_code)

    let destroy =
      foreign "uv_cond_destroy"
        (ptr t @-> returning void)

    let signal =
      foreign "uv_cond_signal"
        (ptr t @-> returning void)

    let broadcast =
      foreign "uv_cond_broadcast"
        (ptr t @-> returning void)
  end

  module Barrier =
  struct
    let t = Types.Barrier.t

    let init =
      foreign "uv_barrier_init"
        (ptr t @-> uint @-> returning error_code)

    let destroy =
      foreign "uv_barrier_destroy"
        (ptr t @-> returning void)
  end

  module Sockaddr =
  struct
    let ip4_addr =
      foreign "uv_ip4_addr"
        (ocaml_string @-> int @-> ptr Types.Sockaddr.in_ @->
         returning error_code)

    let ip6_addr =
      foreign "uv_ip6_addr"
        (ocaml_string @-> int @-> ptr Types.Sockaddr.in6 @->
         returning error_code)

    let ip4_name =
      foreign "uv_ip4_name"
        (ptr Types.Sockaddr.in_ @-> ocaml_bytes @-> size_t @->
         returning error_code)

    let ip6_name =
      foreign "uv_ip6_name"
        (ptr Types.Sockaddr.in6 @-> ocaml_bytes @-> size_t @->
         returning error_code)

    let memcpy_from_sockaddr =
      foreign "memcpy"
        (ptr Types.Sockaddr.storage @-> ptr Types.Sockaddr.t @-> int @->
         returning void)

    let ntohs =
      foreign "ntohs"
        (ushort @-> returning ushort)
  end

  module Resource =
  struct
    let resident_set_memory =
      foreign "uv_resident_set_memory"
        (ptr size_t @-> returning error_code)

    let uptime =
      foreign "uv_uptime"
        (ptr double @-> returning error_code)

    let loadavg =
      foreign "uv_loadavg"
        (ptr double @-> returning void)

    let free_memory =
      foreign "uv_get_free_memory"
        (void @-> returning uint64_t)

    let total_memory =
      foreign "uv_get_total_memory"
        (void @-> returning uint64_t)

    let constrained_memory =
      foreign "uv_get_constrained_memory"
        (void @-> returning uint64_t)

    let getpriority =
      foreign "uv_os_getpriority"
        (int @-> ptr int @-> returning error_code)

    let setpriority =
      foreign "uv_os_setpriority"
        (int @-> int @-> returning error_code)

    let getrusage =
      foreign "uv_getrusage"
        (ptr Types.Resource.Rusage.t @-> returning error_code)
  end

  module Pid =
  struct
    let getpid =
      foreign "uv_os_getpid"
        (void @-> returning int)

    let getppid =
      foreign "uv_os_getppid"
        (void @-> returning int)
  end

  module CPU_info =
  struct
    let t = Types.CPU_info.t

    let cpu_info =
      foreign "uv_cpu_info"
        (ptr (ptr t) @-> ptr int @-> returning error_code)

    let free_cpu_info =
      foreign "uv_free_cpu_info"
        (ptr t @-> int @-> returning void)
  end

  module Network =
  struct
    let interface_addresses =
      foreign "uv_interface_addresses"
        (ptr (ptr Types.Network.Interface_address.t) @-> ptr int @->
         returning error_code)

    let free_interface_addresses =
      foreign "uv_free_interface_addresses"
        (ptr Types.Network.Interface_address.t @-> int @-> returning void)

    let if_indextoname =
      foreign "uv_if_indextoname"
        (uint @-> ocaml_bytes @-> ptr size_t @-> returning error_code)

    let if_indextoiid =
      foreign "uv_if_indextoiid"
        (uint @-> ocaml_bytes @-> ptr size_t @-> returning error_code)

    let gethostname =
      foreign "uv_os_gethostname"
        (ocaml_bytes @-> ptr size_t @-> returning error_code)
  end

  module Path =
  struct
    let exepath =
      foreign "uv_exepath"
        (ocaml_bytes @-> ptr size_t @-> returning error_code)

    let cwd =
      foreign "uv_cwd"
        (ocaml_bytes @-> ptr size_t @-> returning error_code)

    let chdir =
      foreign "uv_chdir"
        (ocaml_string @-> returning error_code)

    let homedir =
      foreign "uv_os_homedir"
        (ocaml_bytes @-> ptr size_t @-> returning error_code)

    let tmpdir =
      foreign "uv_os_tmpdir"
        (ocaml_bytes @-> ptr size_t @-> returning error_code)
  end

  module Passwd =
  struct
    let t = Types.Passwd.t

    let get_passwd =
      foreign "uv_os_get_passwd"
        (ptr t @-> returning error_code)

    let free =
      foreign "uv_os_free_passwd"
        (ptr t @-> returning void)
  end

  module Env =
  struct
    let getenv =
      foreign "uv_os_getenv"
        (ocaml_string @-> ocaml_bytes @-> ptr size_t @-> returning error_code)

    let setenv =
      foreign "uv_os_setenv"
        (ocaml_string @-> ocaml_string @-> returning error_code)

    let unsetenv =
      foreign "uv_os_unsetenv"
        (ocaml_string @-> returning error_code)

    let environ =
      foreign "uv_os_environ"
        (ptr (ptr Types.Env_item.t) @-> ptr int @-> returning error_code)

    let free_environ =
      foreign "uv_os_free_environ"
        (ptr Types.Env_item.t @-> int @-> returning void)
  end

  module Uname =
  struct
    let uname =
      foreign "luv_os_uname"
        (ocaml_bytes @-> returning error_code)
  end

  module Time =
  struct
    let gettimeofday =
      foreign "uv_gettimeofday"
        (ptr Types.Time.Timeval.t @-> returning error_code)

    let hrtime =
      foreign "uv_hrtime"
        (void @-> returning uint64_t)
  end

  module Random =
  struct
    let request = Types.Random.Request.t

    let trampoline =
      static_funptr
        Ctypes.(ptr request @-> error_code @-> ptr void @-> size_t @->
                returning void)

    let get_trampoline =
      foreign "luv_get_random_trampoline"
        (void @-> returning trampoline)

    let get_null_callback =
      foreign "luv_null_random_trampoline"
        (void @-> returning trampoline)

    let random =
      foreign "uv_random"
        (ptr Loop.t @->
         ptr request @->
         ptr char @->
         size_t @->
         uint @->
         trampoline @->
         returning error_code)
  end

  module Metrics =
  struct
    let idle_time =
      foreign "uv_metrics_idle_time"
        (ptr Types.Loop.t @-> returning uint64_t)
  end
end
