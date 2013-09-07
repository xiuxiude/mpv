AC_DEFUN([AX_SETUP_WINDOWS], [
  AC_SUBST([osdep_timer], [timer-win2])
  AC_DEFINE([CONFIG_PRIORITY], [1], [Process priority])
  CFLAGS="$CFLAGS -fno-common"
  LIBS="$LIBS -lwinmm"
  windows="yes"
])

AC_DEFUN([AX_OSDEP], [
  AC_SUBST([osdep_timer], [timer-linux])
  AC_SUBST([osdep_getch], [getch2])

  AS_CASE([${host_os}],
    [*mingw32*], [
      AC_SUBST([osdep_getch], [getch2-win])
      AX_SETUP_WINDOWS
      AC_DEFINE([HAVE_DOS_PATHS], [1], [Use DOS paths])
      CFLAGS="$CFLAGS -D__USE_MINGW_ANSI_STDIO=1"
      # Hack for missing BYTE_ORDER declarations in <sys/types.h>.
      # For some reason, they are in <sys/param.h>, but we don't bother
      # switching the includes based on whether we're compiling for MinGW.
      CFLAGS="$CFLAGS -DBYTE_ORDER=1234 -DLITTLE_ENDIAN=1234 -DBIG_ENDIAN=4321"
    ],
    [*cygwin*],  [
      AX_SETUP_WINDOWS
      CFLAGS="$CFLAGS -mwin32"
    ],
    [*darwin*],  [
      AC_SUBST([osdep_timer], [timer-darwin])
      CFLAGS="$CFLAGS -mdynamic-no-pic"
    ],
    [*linux*],   [],
    [*freebsd*], [],
    [*netbsd*],  [],
  )
  AM_CONDITIONAL([CONFIG_PRIORITY], [test "x$windows" = "xyes"])
])
