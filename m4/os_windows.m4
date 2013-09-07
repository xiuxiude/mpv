AC_DEFUN([OS_WINDOWS_CHECKS],[
  AC_MSG_CHECKING([if building for Windows or Cygwin])
  AM_CONDITIONAL([OS_WINDOWS], [test "x$windows" = "xyes"])
  AM_COND_IF([OS_WINDOWS],[],[windows=no])
  AC_MSG_RESULT([$windows])

  AM_COND_IF([OS_WINDOWS],[
    AX_CC_CHECK_LIBS([-lole32],[WASAPI],[WASAPI],[
#define COBJMACROS 1
#define _WIN32_WINNT 0x600
#include <initguid.h>
#include <mmdeviceapi.h>
#include <audioclient.h>
#include <endpointvolume.h>

int main(void) {
    const GUID *check[[]] = {
      &IID_IAudioClient,
      &IID_IAudioRenderClient,
      &IID_IAudioEndpointVolume,
    };
    (void)check[[0]];

    CoInitialize(NULL);
    IMMDeviceEnumerator *e;
    CoCreateInstance(&CLSID_MMDeviceEnumerator, NULL, CLSCTX_ALL,
                     &IID_IMMDeviceEnumerator, (void **)&e);
    IMMDeviceEnumerator_Release(e);
    CoUninitialize();
}
    ])
    AM_COND_IF([HAVE_WASAPI],[AC_DEFINE([CONFIG_WASAPI],[1],[Define to 1 if WASAPI is enabled (compat with old build system)])])
  ])
])
