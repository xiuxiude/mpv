AC_DEFUN([OS_DARWIN_CHECKS],[
  AC_MSG_CHECKING([if building for Darwin (OS X)])
  AC_COMPILE_IFELSE([AC_LANG_SOURCE([
  #if !defined(__APPLE__) || !defined(__MACH__)
  #error Not Darwin
  #endif
  ])],[os_darwin=yes],[os_darwin=no])
  AM_CONDITIONAL([OS_DARWIN], [test "x$os_darwin" = "xyes"])
  AC_MSG_RESULT([$os_darwin])

  AM_COND_IF([OS_DARWIN],[
      AC_LANG_PUSH([Objective C])

      AX_STASH_BUILD_FLAGS
      LIBS="$LIBS -framework IOKit -framework Cocoa -framework OpenGL"
      OBJCLDFLAGS="-fobjc-arc"
      AX_CC_CHECK([COCOA], [Cocoa Framework (OSX GUI Toolkit)], [
        #include <Cocoa/Cocoa.h>
        #include <CoreServices/CoreServices.h>
        #include <OpenGL/OpenGL.h>
        int main(void) {
          @autoreleasepool {
            NSApplicationLoad();
          }
        }
      ], [
        have_opengl=yes
        have_opengl_cocoa=yes

        AX_CHECK_STATEMENT_LIBS(["-framework QuartzCore"],
          [COREVIDEO], [CoreVideo],
          [QuartzCore/CoreVideo.h], [CVBufferRef buffer])
      ], [
        AX_POP_BUILD_FLAGS
        OBJCLDFLAGS=""
      ])

      AC_LANG_POP([Objective C])

      AX_CC_CHECK_LIBS(
        ["-framework CoreAudio -framework AudioUnit -framework AudioToolbox"],
        [COREAUDIO], [CoreAudio], [
        #include <CoreAudio/CoreAudio.h>
        #include <AudioToolbox/AudioToolbox.h>
        #include <AudioUnit/AudioUnit.h>
        int main(void) { return 0; }
      ])

      LDFLAGS="$LDFLAGS $OBJCLDFLAGS"
  ])

  AM_CONDITIONAL([HAVE_COCOA],[test "x$have_cocoa" = "xyes"])

  AM_CONDITIONAL([HAVE_OPENGL],[test "x$have_opengl" = "xyes"])
  AM_COND_IF([HAVE_OPENGL],[AC_DEFINE([HAVE_OPENGL], [1], [Define 1 if OpenGL is enabled])])

  AM_CONDITIONAL([HAVE_OPENGL_COCOA], [test "x$have_opengl_cocoa" = "xyes"])
  AM_COND_IF([HAVE_OPENGL_COCOA],[AC_DEFINE([HAVE_OPENGL_COCOA], [1], [Define 1 if OpenGL Cocoa backend is enabled])])

  AM_CONDITIONAL([HAVE_COREVIDEO],[test "x$have_corevideo" = "xyes"])
  AM_CONDITIONAL([HAVE_COREAUDIO],[test "x$have_coreaudio" = "xyes"])
])
