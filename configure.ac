# This file is part of mpv.
# Copyright (c) 2013 Stefano Pigozzi
#
# mpv is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# mpv is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with mpv; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

AC_PREREQ([2.69])

AC_INIT([mpv], m4_esyscmd_s([git describe]), [mpv-team@googlegroups.com],
        [mpv], [http://mpv.io])
configure_flags="$*"

AC_CONFIG_SRCDIR([mpvcore/mplayer.c])
AC_CONFIG_HEADERS([config.h])
AM_INIT_AUTOMAKE([1.13 foreign subdir-objects dist-xz silent-rules])
AM_MAINTAINER_MODE([enable])
AM_SILENT_RULES([yes])

AC_PROG_CC_C99
AC_CANONICAL_HOST

# XXX: doesn't look like this adds -lrt and from bfe0207a7 it seems needed
AX_PTHREAD([
  LIBS="$PTHREAD_LIBS $LIBS"
  CFLAGS="$CFLAGS $PTHREAD_CFLAGS"
  CC="$PTHREAD_CC"
])

# XXX: I think the macro is bugged, consider patching that
AS_IF([test "x$ax_pthread_ok" = "xyes"], [
  AC_DEFINE([HAVE_PTHREAD], [1],
            [Define if you have POSIX threads libraries and header files.])
])

# XXX: this generates stuff like `#define MPLAYER_CONFDIR "${prefix}/etc/mpv"`
# this is a good thing since it respects the GNU coding standards and makes
# the package relocatable. See http://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.69/html_node/Defining-Directories.html
# mpv needs to be adapted to acocunt for this
AC_DEFINE_UNQUOTED([MPLAYER_CONFDIR],   ["$sysconfdir/mpv"],
                   ["System level directory to store mpv configuration files"])
AC_DEFINE_UNQUOTED([MPLAYER_LOCALEDIR], ["$datadir/man"],
                   ["System level directory to store mpv locale files"])
AC_DEFINE_UNQUOTED([CONFIGURATION], "$configure_flags",
                   ["Flags passed to ./configure"])

AX_OSDEP

AX_CHECK_STATEMENT([NANOSLEEP], [nanosleep], [time.h], [nanosleep(0, 0)])
AX_CHECK_STATEMENT(
  [SYS_MMAN_H], [mman.h], [sys/mman.h], [mmap(0, 0, 0, 0, 0, 0)])

AC_SEARCH_LIBS([dlopen], [dl], [
  AC_DEFINE([HAVE_LIBDL], [1], [Define 1 if has libdl])
  AM_CONDITIONAL([HAVE_LIBDL], [true])
], [
  AM_CONDITIONAL([HAVE_LIBDL], [false])
])

AX_CHECK_CONDITION([STREAM_CACHE], [stream cache],
                   [test "x$ax_pthread_ok" = "xyes"])

# XXX: rpath test

AX_ICONV
# XXX: add gettext tests

AC_CHECK_HEADERS([sys/soundcard.h soundcard.h], [break])
AC_CHECK_HEADERS([sys/videoio.h])

AX_CHECK_STATEMENT_LIBS(
  ["-lncurses" "-lncursesw" "-ltinfo"], [TERMINFO], [terminfo],
  [term.h], [setupterm(0, 1, 0)])

AX_CHECK_STATEMENT_LIBS(
  ["-lncurses" "-ltinfo" "-ltermcap"], [TERMCAP], [termcap],
  [term.h], [tgetent(0, 0)])

AC_CHECK_HEADERS([termios.h sys/termios.h], [
  AC_DEFINE([HAVE_TERMIOS], [1], [Define to 1 if there is termios support])
  break
])

AX_CHECK_STATEMENT(
  [SHM], [shm], [sys/shm.h], [shmget(0, 0, 0); shmat(0, 0, 0); shmctl(0, 0, 0)])

AX_CHECK_STATEMENT(
  [POSIX_SELECT], [POSIX select()],
  [sys/select.h], [
    int rc;
    rc = select(0, (fd_set *)(0), (fd_set *)(0), (fd_set *)(0),
                (struct timeval *)(0));
  ]
)

AC_ARG_ENABLE([audio_select],
  AS_HELP_STRING([--disable-audio-select],
                 [disable using select() on the audio device]))
AS_IF([test "x$enable_audio_select" != "xno"], [
  AC_DEFINE([HAVE_AUDIO_SELECT], [1],
            [Define to 1 to use select() on audio devices])
])

AX_CHECK_STATEMENT([GLOB], [glob()], [glob.h], [glob("filename", 0, 0, 0)])
# XXX: win32 add need_glob

AX_CHECK_STATEMENT([SETMODE], [setmode()], [io.h], [setmode(0, 0)])

AC_CHECK_HEADERS([sys/sysinfo.h])
# XXX: macosx bundle support check

AX_PKG_ADD([LIBAV],
  [libavutil > 51.73.0 libavcodec > 54.34.0
   libavformat > 54.19.0 libswscale >= 2.0.0])

AS_IF([test "x$with_libav" = "xno"], [
  AC_MSG_ERROR(["Unable to find development files for libav. Aborting."])
])

AX_PKG_ADD([LIBAVRESAMPLE], [libavresample >= 1.0.0])
AX_PKG_ADD([LIBSWRESAMPLE], [libswresample >= 0.17.102])

AS_IF([test "x$with_libavresample" = "xno" &&
       test "x$with_libswresample" = "xno"], [
  AC_MSG_ERROR(["No resampler found. Install libavresample or libswresample."])
])

AS_IF([test "x$with_libavresample" = "xyes"], [
  AX_CHECK_STATEMENT(
    [LIBAVRESAMPLE_SET_CHANNEL_MAPPING], [libavresample set_channel_mapping API],
    [libavresample/avresample.h],
    [avresample_set_channel_mapping(NULL, NULL)])
])

AX_CHECK_STATEMENT(
  [LIBAVCODEC_NEW_VDPAU_API], [libavcodec new VDPAU API],
  [libavutil/pixfmt.h],
  [int x = AV_PIX_FMT_VDPAU])

AX_CHECK_STATEMENT(
  [LIBAVCODEC_PROP_TEXT_SUB], [libavcodec AV_CODEC_PROP_TEXT_SUB API],
  [libavcodec/avcodec.h],
  [int x = AV_CODEC_PROP_TEXT_SUB])

AX_CHECK_STATEMENT(
  [LIBAVCODEC_CHROMA_POS_API], [libavcodec enum_to_chroma_pos API],
  [libavcodec/avcodec.h],
  [int x, y; avcodec_enum_to_chroma_pos(&x, &y, AVCHROMA_LOC_UNSPECIFIED)])

AX_CHECK_STATEMENT(
  [LIBAVUTIL_QP_API], [libavutil QP API],
  [libavutil/frame.h],
  [av_frame_get_qp_table(NULL, NULL, NULL)])

AX_CHECK_STATEMENT(
  [LIBAVUTIL_REFCOUNTING], [libavutil ref-counting API],
  [libavutil/frame.h],
  [av_frame_unref(NULL)])

AX_CHECK_STATEMENT(
  [LIBAVUTIL_OPT_SET_INT_LIST], [libavutil av_opt_set_int_list API],
  [libavutil/opt.h],
  [av_opt_set_int_list(0,0,(int*)0,0,0)])

AX_STASH_BUILD_FLAGS
AX_PKG_ADD([LIBAVFILTER], [libavfilter])

AX_CC_CHECK(
  [LIBAVFILTER_NOT_OLD_OR_BROKEN], [libavfilter not old or broken],
  [
    #include <libavfilter/avfilter.h>
    void vf_next_query_format() {}
    int main(void) {
        avfilter_register_all();
        vf_next_query_format();
        return 0;
    }
  ], [ ], [AX_POP_BUILD_FLAGS])

AS_IF([test "x$have_libavfilter_not_old_or_broken" = "xyes"], [
  AX_CHECK_CONDITION([LIBAVFILTER_USABLE_WITH_VF_LAVFI],
                     [libavfilter is usable through vf_lavfi],
                     [test "x$have_libavutil_refcounting" = "xyes"])

  AX_CHECK_CONDITION([LIBAVFILTER_USABLE_WITH_AF_LAVFI],
                     [libavfilter is usable through af_lavfi],
                     [test "x$have_libavutil_opt_set_int_list" = "xyes"])
], [
  AM_CONDITIONAL([HAVE_LIBAVFILTER_USABLE_WITH_VF_LAVFI], [false])
  AM_CONDITIONAL([HAVE_LIBAVFILTER_USABLE_WITH_AF_LAVFI], [false])
])

AX_PKG_ADD([LIBAVDEVICE], [libavdevice >= 54.0.0])
AX_PKG_ADD([LIBPOSTPROC], [libpostproc >= 52.0.0])

AX_PKG_ADD([LIBASS], [libass])

AC_ARG_ENABLE([libass_osd],
  AS_HELP_STRING([--disable-libass-osd], [disable libass OSD support]))

AM_CONDITIONAL(HAVE_LIBASS_OSD,
  [test "x$enable_libass_osd" != "xno" && test "x$with_libass" = "xyes"])

AX_PKG_ADD([LIBGUESS], [libguess >= 1.0])

AX_CHECK_STATEMENT_LIBS(
  ["-lsmbclient" "-lsmbclient -lnsl" "-lsmbclient -lnsl -lssl"],
  [LIBSMBCLIENT], [Samba support (libsmbclient)],
  [libsmbclient.h], [smbc_opendir("smb://")])

AX_PKG_ADD([LIBQUVI4], [libquvi >= 0.4.1])

AS_IF([test "x$with_libquvi4" = "xno"], [
  AX_PKG_ADD([LIBQUVI9], [libquvi >= 0.9.0])
], [
  # AM_CONDITIONAL must be invoked on all branches. Since AX_PKG_ADD invokes
  # it, invoke it here as well to 'disable' LIBQUVI9
  AM_CONDITIONAL([HAVE_LIBQUVI9], [false])
])

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

# XXX: make all this conditional and based on platform? (will require a LOT
# of AM_CONDITIONAL hacks..)
AC_PROG_OBJC([clang])
AC_LANG_PUSH([Objective C])

# XXX: AM_COND_IF does not "conditionalize" AC_PROG_OBJC
# we check it before so the configure output looks less weird :P
AC_PROG_OBJC([clang])

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

AC_MSG_CHECKING([whether encoding is enabled])
AC_ARG_ENABLE([encoding],
  [AS_HELP_STRING([--disable-encoding], [disable support for encoding])])
AM_CONDITIONAL([CONFIG_ENCODING],[test "x$enable_encoding" != "xno"])
AM_COND_IF([CONFIG_ENCODING],[
  enable_encoding=yes
  AC_DEFINE([CONFIG_ENCODING],[1],[Define to 1 if encoding is supported (compat)])])
AC_MSG_RESULT([$enable_encoding])

AC_CONFIG_MACRO_DIR([m4])
AC_OUTPUT([Makefile])
