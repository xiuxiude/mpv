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
AM_INIT_AUTOMAKE([1.11 foreign subdir-objects dist-xz silent-rules])
AM_MAINTAINER_MODE([enable])
AM_SILENT_RULES([yes])

AC_PROG_CC_C99
AC_CANONICAL_HOST

AX_PTHREAD([
  LIBS="$PTHREAD_LIBS $LIBS"
  CFLAGS="$CFLAGS $PTHREAD_CFLAGS"
  CC="$PTHREAD_CC"
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

AX_CHECK_STATEMENT_LIBS(
  ["" "-ldl"], [LIBDL], [libdl], [dlfcn.h], [dlopen("", 0)])

AX_CHECK_CONDITION([STREAM_CACHE], [stream cache],
                   [test "x$ax_pthread_ok" = "xyes"])

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
  [libavfilter/avfilter.h],
  [
    #include <libavfilter/avfilter.h>
    void vf_next_query_format() {}
    int main(void) {
        avfilter_register_all();
        vf_next_query_format();
        return 0;
    }
  ])

AS_IF([test "x$have_libavfilter_not_old_or_broken" = "xno"], [
  AX_POP_BUILD_FLAGS
])

AC_MSG_CHECKING([if libavfilter is usable through vf_lavfi])
AS_IF([test "x$have_libavfilter_not_old_or_broken" = "xyes"], [
  AS_IF([test "x$have_libavutil_refcounting" = "xyes"], [
    AC_DEFINE([LIBAVFILTER_USABLE_WITH_VF_LAVFI], [],
              [Define 1 if libavfilter is usable through vf_lavfi])
    AC_MSG_RESULT([yes])
  ],[
    AC_MSG_RESULT([no (libavutil too old)])
  ])
],[
  AC_MSG_RESULT([no])
])

AC_MSG_CHECKING([if libavfilter is usable through af_lavfi])
AS_IF([test "x$have_libavfilter_not_old_or_broken" = "xyes"], [
  AS_IF([test "x$have_libavutil_opt_set_int_list" = "xyes"], [
    AC_DEFINE([LIBAVFILTER_USABLE_WITH_AF_LAVFI], [],
              [Define 1 if libavfilter is usable through af_lavfi])
    AC_MSG_RESULT([yes])
  ],[
    AC_MSG_RESULT([no (libavutil too old)])
  ])
],[
  AC_MSG_RESULT([no])
])

AX_PKG_ADD([LIBAVDEVICE], [libavdevice >= 54.0.0])
AX_PKG_ADD([LIBPOSTPROC], [libpostproc >= 52.0.0])

AX_PKG_ADD([LIBASS], [libass])

AC_ARG_ENABLE([libass_osd],
  AS_HELP_STRING([--disable-libass-osd], [Disable libass OSD support]))

AM_CONDITIONAL(HAVE_LIBASS_OSD,
  [test "x$enable_libass_osd" != "xno" && test "x$with_libass" = "xyes"])

AC_CONFIG_MACRO_DIR([m4])
AC_OUTPUT([Makefile])
