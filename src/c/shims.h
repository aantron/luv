// This file is part of Luv, released under the MIT license. See LICENSE.md for
// details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md.



#if UV_VERSION_MAJOR == 1 && UV_VERSION_MINOR < 40
    #define UV_UDP_MMSG_FREE 0

    static uint64_t uv_timer_get_due_in(const uv_timer_t *timer)
    {
        return 0;
    }
#endif
