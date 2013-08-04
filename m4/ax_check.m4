# Convenience macro to run AM_CONDITIONAL, AC_DEFINE and to define a shell
# variable after running a compilation check of some sort
# ----------------------------------------------------------------------------
AC_DEFUN([AX_CC_CHECK_BASE], [
  AC_MSG_CHECKING([for $2])
  AC_LINK_IFELSE(
    $3,
    [
      AC_DEFINE([HAVE_][$1], [], [Define 1 if has $2])
      AC_MSG_RESULT([yes])
      AS_TR_SH([have_]m4_tolower([$1]))="yes"
    ],
    [
      AC_MSG_RESULT([no])
      AS_TR_SH([have_]m4_tolower([$1]))="no"
    ]
  )
  AM_CONDITIONAL([HAVE_][$1],
                 [test "$AS_TR_SH([with_]m4_tolower([$1]))" = "yes"])
])

AC_DEFUN([AX_CHECK_STATEMENT], [
  AX_CC_CHECK_BASE([$1],[$2],[[AC_LANG_PROGRAM([[#include <$3>]], [[$4;]])]])
])

AC_DEFUN([AX_CC_CHECK], [
  AX_CC_CHECK_BASE([$1],[$2],[[AC_LANG_SOURCE([$3])]])
])

AC_DEFUN([AX_STASH_BUILD_FLAGS], [
  _stashed_cflags=$CFLAGS
  _stashed_libs=$LIBS
])

AC_DEFUN([AX_POP_BUILD_FLAGS], [
  CFLAGS=$_stashed_cflags
  LIBS=$_stashed_libs
])
