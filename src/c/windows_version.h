// This file is part of Luv, released under the MIT license. See LICENSE.md for
// details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md.



#pragma once

#ifndef LUV_WINDOWS_VERSION_H_
#define LUV_WINDOWS_VERSION_H_

#ifdef _WIN32
#include <WinSDKVer.h>
#define WINVER _WIN32_WINNT_VISTA
#define _WIN32_WINNT _WIN32_WINNT_VISTA
#include <sdkddkver.h>
#include <ws2tcpip.h>
#endif

#if defined(_MSC_VER)
# include <sys/stat.h>
# if defined(_S_IFIFO)
#  define S_IFIFO _S_IFIFO
# endif
# ifndef S_IXUSR
#  define S_IXUSR _S_IEXEC
# endif
# ifndef S_IWUSR
#  define S_IWUSR _S_IWRITE
# endif
# ifndef S_IRUSR
#  define S_IRUSR _S_IREAD
# endif
# ifndef S_IRWXU
#  define S_IRWXU (_S_IREAD | _S_IWRITE | _S_IEXEC)
# endif
/* Windows has no block devices. Defining S_IFBLK was a mistake in MinGW: https://sourceforge.net/p/mingw/bugs/1146/
   For parity with the MinGW luv port we re-use MinGW's constant. Libuv 1.42.0 does not use S_IFBLK anyway.
 */
# define S_IFBLK 0x3000
/* Windows does not support POSIX "others" and "groups". Use same settings as src.c/vendor/configure/ltmain.sh */
# ifndef S_IXOTH
#  define S_IXOTH 0
# endif
# ifndef S_IXGRP
#  define S_IXGRP 0
# endif
/* Libuv 1.42 uses `| S_IRGRP | S_IROTH` and `| S_IWGRP | S_IWOTH` etc. to add POSIX permissions for "others" and "groups"
like in src/c/vendor/libuv/src/unix/pipe.c. That means we can use zero (0) just like ltmain.sh did for
S_IXOTH and S_IXGRP. */
# ifndef S_IROTH
#  define S_IROTH 0
# endif
# ifndef S_IRGRP
#  define S_IRGRP 0
# endif
# ifndef S_IWOTH
#  define S_IWOTH 0
# endif
# ifndef S_IWGRP
#  define S_IWGRP 0
# endif
# ifndef S_IRWXO
#  define S_IRWXO 0
# endif
# ifndef S_IRWXG
#  define S_IRWXG 0
# endif
#endif

#endif // #ifndef LUV_WINDOWS_VERSION_H_
