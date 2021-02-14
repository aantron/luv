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