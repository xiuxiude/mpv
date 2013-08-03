AC_DEFUN([MP_DEFINE_OS], [
  AC_DEFINE([$1], [], [$1])
  $1="yes"
])

AC_DEFUN([MP_DEFINE_OS_VARIABLES], [
  AS_CASE([${host_os}],
      [*linux*],   [MP_DEFINE_OS(HAVE_OS_LINUX)],
      [*win32*],   [MP_DEFINE_OS(HAVE_OS_WINDOWS)],
      [*darwin*],  [MP_DEFINE_OS(HAVE_OS_OSX)],
      [*freebsd*], [MP_DEFINE_OS(HAVE_OS_FREEBSD)],
  )
  AM_CONDITIONAL([HAVE_OS_LINUX],   [test $HAVE_OS_LINUX="yes"])
  AM_CONDITIONAL([HAVE_OS_WINDOWS], [test $HAVE_OS_WINDOWS="yes"])
  AM_CONDITIONAL([HAVE_OS_OSX],     [test $HAVE_OS_OSX="yes"])
  AM_CONDITIONAL([HAVE_OS_FREEBSD], [test $HAVE_OS_FREEBSD="yes"])
])
