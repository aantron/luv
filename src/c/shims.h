// This file is part of Luv, released under the MIT license. See LICENSE.md for
// details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md.



#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 12
    static int uv_loop_fork(uv_loop_t* loop)
    {
        return ENOSYS;
    }

    static int uv_signal_start_oneshot(
        uv_signal_t *signal, uv_signal_cb callback, int number)
    {
        return ENOSYS;
    }

    static uv_os_fd_t uv_get_osfhandle(int fd)
    {
        return fd;
    }

    static int uv_os_getenv(const char *name, char *buffer, size_t *size)
    {
        return ENOSYS;
    }
    static int uv_os_setenv(const char *name, const char *value)
    {
        return ENOSYS;
    }
    static int uv_os_unsetenv(const char *name)
    {
        return ENOSYS;
    }

    static int uv_os_gethostname(char *buffer, size_t *size)
    {
        return ENOSYS;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 14
    #define UV_PRIORITIZED 0

    #define UV_FS_COPYFILE_EXCL 0
    static int uv_fs_copyfile(
        uv_loop_t *loop, uv_fs_t *request, const char *path,
        const char *new_path, int flags, uv_fs_cb callback)
    {
        return ENOSYS;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 15
    static int uv_mutex_init_recursive(uv_mutex_t *mutex)
    {
        return ENOSYS;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 16
    #define UV_ENOTTY 0x24242424

    // UV_FS_O_* flag definitions directly taken from uv/unix.h and uv/win.h as
    // of libuv 1.41.0.
    #if defined(_WIN32)
        #define UV_FS_O_APPEND _O_APPEND
        #define UV_FS_O_CREAT _O_CREAT
        #define UV_FS_O_DIRECT 0x02000000
        #define UV_FS_O_DSYNC 0x04000000
        #define UV_FS_O_EXCL _O_EXCL
        #define UV_FS_O_EXLOCK 0x10000000
        #define UV_FS_O_NOATIME 0
        #define UV_FS_O_NOCTTY 0
        #define UV_FS_O_NOFOLLOW 0
        #define UV_FS_O_NONBLOCK 0
        #define UV_FS_O_RANDOM _O_RANDOM
        #define UV_FS_O_RDONLY _O_RDONLY
        #define UV_FS_O_RDWR _O_RDWR
        #define UV_FS_O_SEQUENTIAL _O_SEQUENTIAL
        #define UV_FS_O_SHORT_LIVED _O_SHORT_LIVED
        #define UV_FS_O_SYMLINK 0
        #define UV_FS_O_SYNC 0x08000000
        #define UV_FS_O_TEMPORARY _O_TEMPORARY
        #define UV_FS_O_TRUNC _O_TRUNC
        #define UV_FS_O_WRONLY _O_WRONLY
    #else
        #if defined(O_APPEND)
            #define UV_FS_O_APPEND O_APPEND
        #else
            #define UV_FS_O_APPEND 0
        #endif
        #if defined(O_CREAT)
            #define UV_FS_O_CREAT O_CREAT
        #else
            #define UV_FS_O_CREAT 0
        #endif
        #if defined(__linux__) && defined(__arm__)
            #define UV_FS_O_DIRECT 0x10000
        #elif defined(__linux__) && defined(__m68k__)
            #define UV_FS_O_DIRECT 0x10000
        #elif defined(__linux__) && defined(__mips__)
            #define UV_FS_O_DIRECT 0x08000
        #elif defined(__linux__) && defined(__powerpc__)
            #define UV_FS_O_DIRECT 0x20000
        #elif defined(__linux__) && defined(__s390x__)
            #define UV_FS_O_DIRECT 0x04000
        #elif defined(__linux__) && defined(__x86_64__)
            #define UV_FS_O_DIRECT 0x04000
        #elif defined(O_DIRECT)
            #define UV_FS_O_DIRECT O_DIRECT
        #else
            #define UV_FS_O_DIRECT 0
        #endif
        #if defined(O_DSYNC)
            #define UV_FS_O_DSYNC O_DSYNC
        #else
            #define UV_FS_O_DSYNC 0
        #endif
        #if defined(O_EXCL)
            #define UV_FS_O_EXCL O_EXCL
        #else
            #define UV_FS_O_EXCL 0
        #endif
        #if defined(O_EXLOCK)
            #define UV_FS_O_EXLOCK O_EXLOCK
        #else
            #define UV_FS_O_EXLOCK 0
        #endif
        #if defined(O_NOATIME)
            #define UV_FS_O_NOATIME O_NOATIME
        #else
            #define UV_FS_O_NOATIME 0
        #endif
        #if defined(O_NOCTTY)
            #define UV_FS_O_NOCTTY O_NOCTTY
        #else
            #define UV_FS_O_NOCTTY 0
        #endif
        #if defined(O_NOFOLLOW)
            #define UV_FS_O_NOFOLLOW O_NOFOLLOW
        #else
            #define UV_FS_O_NOFOLLOW 0
        #endif
        #if defined(O_NONBLOCK)
            #define UV_FS_O_NONBLOCK O_NONBLOCK
        #else
            #define UV_FS_O_NONBLOCK 0
        #endif
        #define UV_FS_O_RANDOM 0
        #if defined(O_RDONLY)
            #define UV_FS_O_RDONLY O_RDONLY
        #else
            #define UV_FS_O_RDONLY 0
        #endif
        #if defined(O_RDWR)
            #define UV_FS_O_RDWR O_RDWR
        #else
            #define UV_FS_O_RDWR 0
        #endif
        #define UV_FS_O_SEQUENTIAL 0
        #define UV_FS_O_SHORT_LIVED 0
        #if defined(O_SYMLINK)
            #define UV_FS_O_SYMLINK O_SYMLINK
        #else
            #define UV_FS_O_SYMLINK 0
        #endif
        #if defined(O_SYNC)
            #define UV_FS_O_SYNC O_SYNC
        #else
            #define UV_FS_O_SYNC 0
        #endif
        #define UV_FS_O_TEMPORARY 0
        #if defined(O_TRUNC)
            #define UV_FS_O_TRUNC O_TRUNC
        #else
            #define UV_FS_O_TRUNC 0
        #endif
        #if defined(O_WRONLY)
            #define UV_FS_O_WRONLY O_WRONLY
        #else
            #define UV_FS_O_WRONLY 0
        #endif
    #endif

    #if defined(IF_NAMESIZE)
        #define UV_IF_NAMESIZE (IF_NAMESIZE + 1)
    #elif defined(IFNAMSIZ)
        #define UV_IF_NAMESIZE (IFNAMSIZ + 1)
    #else
        #define UV_IF_NAMESIZE (16 + 1)
    #endif

    static int uv_pipe_chmod(uv_pipe_t *pipe, int flags)
    {
        return ENOSYS;
    }

    typedef int uv_pid_t;
    static uv_pid_t uv_os_getppid()
    {
        return 0;
    }

    static int uv_if_indextoname(
        unsigned int interface, char *buffer, size_t *size)
    {
        return ENOSYS;
    }
    static int uv_if_indextoiid(
        unsigned int interface, char *buffer, size_t *size)
    {
        return ENOSYS;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 18
    static uv_pid_t uv_os_getpid()
    {
        return 0;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 19
    static uv_loop_t* uv_handle_get_loop(const uv_handle_t *handle)
    {
        return handle->loop;
    }
    static void* uv_handle_get_data(const uv_handle_t *handle)
    {
        return handle->data;
    }
    static void* uv_handle_set_data(uv_handle_t *handle, void *data)
    {
        handle->data = data;
        return data;
    }

    static void* uv_req_get_data(const uv_req_t *request)
    {
        return request->data;
    }
    static void* uv_req_set_data(uv_req_t *request, void *data)
    {
        request->data = data;
        return data;
    }
    static const char* uv_req_type_name(uv_req_type type)
    {
        return NULL;
    }

    static size_t uv_stream_get_write_queue_size(const uv_stream_t *stream)
    {
        return stream->write_queue_size;
    }

    static size_t uv_udp_get_send_queue_size(const uv_udp_t *udp)
    {
        return udp->send_queue_size;
    }
    static size_t uv_udp_get_send_queue_count(const uv_udp_t *udp)
    {
        return udp->send_queue_count;
    }

    static uv_pid_t uv_process_get_pid(const uv_process_t *process)
    {
        return process->pid;
    }

    static ssize_t uv_fs_get_result(const uv_fs_t *request)
    {
        return request->result;
    }
    static void* uv_fs_get_ptr(const uv_fs_t *request)
    {
        return request->ptr;
    }
    static const char* uv_fs_get_path(const uv_fs_t *request)
    {
        return request->path;
    }
    static uv_stat_t* uv_fs_get_statbuf(uv_fs_t *request)
    {
        return &request->statbuf;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 20
    #define UV_FS_COPYFILE_FICLONE 0
    #define UV_FS_COPYFILE_FICLONE_FORCE 0
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 21
    #define UV_EFTYPE 0x14242424
    #define UV_OVERLAPPED_PIPE 0

    static int uv_fs_lchown(
        uv_loop_t *loop, uv_fs_t *request, const char *path, uv_uid_t user,
        uv_gid_t group, uv_fs_cb callback)
    {
        return ENOSYS;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 22
    static char* uv_strerror_r(int error, char *buffer, size_t length)
    {
        strncpy(buffer, uv_strerror(error), length - 1);
        buffer[length] = 0;
        return buffer;
    }

    static char* uv_err_name_r(int error, char *buffer, size_t length)
    {
        strncpy(buffer, uv_err_name(error), length - 1);
        buffer[length] = 0;
        return buffer;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 23
    static int uv_open_osfhandle(uv_os_fd_t os_fd)
    {
        return (int)os_fd;
    }

    static int uv_os_getpriority(uv_pid_t pid, int *priority)
    {
        return ENOSYS;
    }
    static int uv_os_setpriority(uv_pid_t pid, int priority)
    {
        return ENOSYS;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 24
    #define UV_PROCESS_WINDOWS_HIDE_CONSOLE 0
    #define UV_PROCESS_WINDOWS_HIDE_GUI 0
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 25
    typedef struct {
        char sysname[256];
        char release[256];
        char version[256];
        char machine[256];
    } uv_utsname_t;
    static int uv_os_uname(uv_utsname_t *buffer)
    {
        return ENOSYS;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 26
    typedef struct {
        enum {
            UV_THREAD_NO_FLAGS = 0x00,
            UV_THREAD_HAS_STACK_SIZE = 0x01
        } flags;
        size_t stack_size;
    } uv_thread_options_t;
    static int uv_thread_create_ex(
        uv_thread_t *id, const uv_thread_options_t *options, uv_thread_cb entry,
        void* argument)
    {
        return uv_thread_create(id, entry, argument);
    }

    #ifdef MAXHOSTNAMELEN
        #define UV_MAXHOSTNAMESIZE (MAXHOSTNAMELEN + 1)
    #else
        #define UV_MAXHOSTNAMESIZE 256
    #endif
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 27
    static int uv_udp_connect(uv_udp_t *udp, const struct sockaddr *addr)
    {
        return ENOSYS;
    }
    static int uv_udp_getpeername(
        const uv_udp_t *udp, struct sockaddr *name, int *namelen)
    {
        return ENOSYS;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 28
    typedef struct {int64_t tv_sec; int32_t tv_usec;} uv_timeval64_t;
    static int uv_gettimeofday(uv_timeval64_t *tv)
    {
        return ENOSYS;
    }

    typedef struct {uv_dirent_t *dirents; size_t nentries;} uv_dir_t;
    static int uv_fs_opendir(
        uv_loop_t *loop, uv_fs_t *request, const char *path, uv_fs_cb callback)
    {
        return ENOSYS;
    }
    static int uv_fs_closedir(
        uv_loop_t *loop, uv_fs_t *request, uv_dir_t *dir, uv_fs_cb callback)
    {
        return ENOSYS;
    }
    static int uv_fs_readdir(
        uv_loop_t *loop, uv_fs_t *request, uv_dir_t* dir, uv_fs_cb callback)
    {
        return ENOSYS;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 29
    static uint64_t uv_get_constrained_memory()
    {
        return 0;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 31
    #define UV_FS_O_FILEMAP 0

    typedef struct {
        uint64_t f_type;
        uint64_t f_bsize;
        uint64_t f_blocks;
        uint64_t f_bfree;
        uint64_t f_bavail;
        uint64_t f_files;
        uint64_t f_ffree;
        uint64_t f_spare[4];
    } uv_statfs_t;
    static int uv_fs_statfs(
        uv_loop_t *loop, uv_fs_t *request, const char* path, uv_fs_cb callback)
    {
        return ENOSYS;
    }

    typedef struct {char *name; char *value;} uv_env_item_t;
    static int uv_os_environ(uv_env_item_t **items, int *count)
    {
        return ENOSYS;
    }
    static void uv_os_free_environ(uv_env_item_t *items, int count)
    {
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 32
    #define UV_EILSEQ 0x04242424

    static int uv_tcp_close_reset(uv_tcp_t *handle, uv_close_cb close_callback)
    {
        return ENOSYS;
    }

    static int uv_udp_set_source_membership(
        uv_udp_t *handle, const char *multicast_addr,
        const char *interface_addr, const char *source_addr,
        uv_membership membership)
    {
        return ENOSYS;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 33
    typedef int uv_random_t;
    typedef void (*uv_random_cb)(
        uv_random_t *request, int status, void* buffer, size_t length);
    static int uv_random(
        uv_loop_t *loop, uv_random_t *request, void *buffer, size_t length,
        unsigned int flags, uv_random_cb callback)
    {
        return ENOSYS;
    }

    typedef enum {UV_TTY_SUPPORTED, UV_TTY_UNSUPPORTED} uv_tty_vtermstate_t;
    static void uv_tty_set_vterm_state(uv_tty_vtermstate_t state)
    {
    }
    static int uv_tty_get_vterm_state(uv_tty_vtermstate_t *state)
    {
        return ENOTSUP;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 34
    static int uv_fs_mkstemp(
        uv_loop_t *loop, uv_fs_t *request, const char *template,
        uv_fs_cb callback)
    {
        return ENOSYS;
    }

    static void uv_sleep(unsigned int msec)
    {
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 35
    #define UV_UDP_MMSG_CHUNK 0
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 36
    static int uv_fs_lutime(
        uv_loop_t *loop, uv_fs_t *request, const char *path, double atime,
        double mtime, uv_fs_cb callback)
    {
        return ENOSYS;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 37
    #define UV_UDP_RECVMMSG 0
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 38
    static void uv_library_shutdown()
    {
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 39
    #define UV_METRICS_IDLE_TIME 0

    static uint64_t uv_metrics_idle_time(uv_loop_t *loop)
    {
        return 0;
    }

    static int uv_udp_using_recvmmsg(uv_udp_t *udp)
    {
        return 0;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 40
    #define UV_UDP_MMSG_FREE 0

    static uint64_t uv_timer_get_due_in(const uv_timer_t *timer)
    {
        return 0;
    }
#endif
