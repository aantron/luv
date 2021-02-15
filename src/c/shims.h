// This file is part of Luv, released under the MIT license. See LICENSE.md for
// details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md.



#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 40
    #define UV_UDP_MMSG_FREE 0

    static uint64_t uv_timer_get_due_in(const uv_timer_t *timer)
    {
        return 0;
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

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 38
    static void uv_library_shutdown()
    {
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 37
    #define UV_UDP_RECVMMSG 0
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 36
    static int uv_fs_lutime(
        uv_loop_t *loop, uv_fs_t *request, const char *path, double atime,
        double mtime, uv_fs_cb callback)
    {
        return ENOSYS;
    }
#endif

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 35
    #define UV_UDP_MMSG_CHUNK 0
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

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 29
    static uint64_t uv_get_constrained_memory()
    {
        return 0;
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

#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 24
    #define UV_PROCESS_WINDOWS_HIDE_CONSOLE 0
    #define UV_PROCESS_WINDOWS_HIDE_GUI 0
#endif
