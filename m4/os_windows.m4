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

    AX_CC_CHECK_LIBS(["-lopengl32 -lgdi32"],[OPENGL],[OpenGL],[
#include <windows.h>
#include <GL/gl.h>
#include <GL/glext.h>

int main(void) {
  HDC dc;
  wglCreateContext(dc);
  glFinish();
  return !GL_INVALID_FRAMEBUFFER_OPERATION;
}
    ])
  ])

  AM_CONDITIONAL([HAVE_OPENGL],[test "x$have_opengl" = "xyes"])
  AM_COND_IF([HAVE_OPENGL],[
    AC_DEFINE([CONFIG_GL], [1], [Define 1 if OpenGL is enabled (compat)])
    AC_DEFINE([CONFIG_GL_WIN32], [1], [Define 1 if OpenGL on Win32 is enabled (compat)])
    AC_DEFINE([HAVE_OPENGL], [1], [Define 1 if OpenGL is enabled])
    AC_DEFINE([HAVE_OPENGL_WIN32], [1], [Define 1 if OpenGL on Win32 is enabled])])
])
