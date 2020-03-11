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

#endif // #ifndef LUV_WINDOWS_VERSION_H_
