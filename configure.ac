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

AC_CONFIG_SRCDIR([core/mplayer.c])
AC_CONFIG_HEADERS([config.h])
AM_INIT_AUTOMAKE([1.11 foreign subdir-objects dist-xz silent-rules])
AM_MAINTAINER_MODE([enable])

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

AX_PKG_ADD(LIBAV,
  [libavutil > 51.73.0 libavcodec > 54.34.0 libavformat > 54.19.0 libswscale >= 2.0.0])

AS_IF([test "$with_libav" = "no"], [
  AC_MSG_ERROR(["Unable to find development files for libav. Aborting."])
])

AX_PKG_ADD(LIBAVRESAMPLE, [libavresample >= 1.0.0])
AX_PKG_ADD(LIBSWRESAMPLE, [libswresample >= 0.17.102])

AS_IF([test "$with_libavresample" = "no" &&
       test "$with_libswresample" = "no"], [
  AC_MSG_ERROR(["No resampler found. Install libavresample or libswresample."])
])

AS_IF([test "$with_libavresample" = "yes"], [
  AX_CHECK_STATEMENT(
    [AVRESAMPLE_SET_CHANNEL_MAPPING], [libavresample set_channel_mapping API],
    [libavresample/avresample.h],
    [avresample_set_channel_mapping(NULL, NULL)])
])

AX_CHECK_STATEMENT(
  [AVCODEC_NEW_VDPAU_API], [libavcodec new VDPAU API],
  [libavutil/pixfmt.h],
  [int x = AV_PIX_FMT_VDPAU])

AX_CHECK_STATEMENT(
  [AVCODEC_PROP_TEXT_SUB], [libavcodec AV_CODEC_PROP_TEXT_SUB API],
  [libavcodec/avcodec.h],
  [int x = AV_CODEC_PROP_TEXT_SUB])

AX_CHECK_STATEMENT(
  [AVCODEC_CHROMA_POS_API], [libavcodec enum_to_chroma_pos API],
  [libavcodec/avcodec.h],
  [int x, y; avcodec_enum_to_chroma_pos(&x, &y, AVCHROMA_LOC_UNSPECIFIED)])

AX_CHECK_STATEMENT(
  [AVUTIL_QP_API], [libavutil QP API],
  [libavutil/frame.h],
  [av_frame_get_qp_table(NULL, NULL, NULL)])

AX_CHECK_STATEMENT(
  [AVUTIL_REFCOUNTING], [libavutil ref-counting API],
  [libavutil/frame.h],
  [av_frame_unref(NULL)])

AX_STASH_BUILD_FLAGS
AX_PKG_ADD(LIBAVFILTER, [libavfilter])

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

AS_IF([test "$have_libavfilter_not_old_or_broken" = "no"], [
  AX_POP_BUILD_FLAGS
])

AC_CONFIG_MACRO_DIR([m4])
AC_OUTPUT([Makefile])
