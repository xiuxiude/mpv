# Convenience macros to run AM_CONDITIONAL, AC_DEFINE and to define a shell
# variable after running a compilation or conditional check of some sort
# ----------------------------------------------------------------------------

AC_DEFUN([AX_CHECK_PASSED], [
  AC_DEFINE([HAVE_][$1], [], [Define 1 if has $2])
  AS_TR_SH([have_]m4_tolower([$1]))="yes"
  AM_CONDITIONAL([HAVE_][$1], [true])
])

AC_DEFUN([AX_CHECK_FAILED], [
  AS_TR_SH([have_]m4_tolower([$1]))="no"
  AM_CONDITIONAL([HAVE_][$1], [false])
])

AC_DEFUN([AX_CHECK_SILENT], [
  AC_LINK_IFELSE(
    $3,
    [
      AX_CHECK_PASSED([$1], [$2])
      $4
    ],
    [
      AX_CHECK_FAILED([$1])
      $5
    ]
  )
])

AC_DEFUN([AX_CC_CHECK_BASE], [
  AC_MSG_CHECKING([for $2])
  AX_CHECK_SILENT(
    [$1], [$2], [$3], [AC_MSG_RESULT([yes])], [AC_MSG_RESULT([no])])
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

AC_DEFUN([AX_CC_CHECK_BASE_LIB],[
  AX_STASH_BUILD_FLAGS
  LIBS="$LIBS $1"
  AX_CHECK_SILENT([$2], [$3], [$4], [AC_MSG_RESULT([yes])], [AX_POP_BUILD_FLAGS])
])

AC_DEFUN([AX_CC_CHECK_BASE_LIBS], [
  AC_MSG_CHECKING([for $3])
  for _lib_tmp in $1; do
    AX_STASH_BUILD_FLAGS
    LIBS="$LIBS $_lib_tmp"
    AX_CHECK_SILENT([$2], [$3], [$4], [], [])
    if test x"$AS_TR_SH([have_]m4_tolower([$2]))" = xyes; then
      break
    else
      AX_POP_BUILD_FLAGS
    fi
  done

  AS_IF([test "x$AS_TR_SH([have_]m4_tolower([$2]))" = "xyes"], [
    AC_MSG_RESULT([yes])
  ], [
    AC_MSG_RESULT([no])
  ])
])

AC_DEFUN([AX_CHECK_STATEMENT_LIBS], [
  AX_CC_CHECK_BASE_LIBS([$1],[$2],[$3],[[AC_LANG_PROGRAM([[#include <$4>]], [[$5;]])]])
])

AC_DEFUN([AX_CHECK_CONDITION], [
  AC_MSG_CHECKING([for $2])
  AS_IF([$3], [
    AX_CHECK_PASSED([$1], [$2])
    AC_MSG_RESULT([yes])
  ], [
    AX_CHECK_FAILED([$1])
    AC_MSG_RESULT([no])
  ])
])
