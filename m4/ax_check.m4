AC_DEFUN([AX_CHECK_STATEMENT], [
  AC_MSG_CHECKING([for $2])
  AC_LINK_IFELSE([
    AC_LANG_PROGRAM(
      [[#include <$3>]],
      [[$4;]]
    )],
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
])
