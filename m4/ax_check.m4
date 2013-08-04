AC_DEFUN([AX_CHECK_STATEMENT], [
  AC_MSG_CHECKING([for $4])
  AC_LINK_IFELSE([
    AC_LANG_PROGRAM(
      [[#include <$1>]],
      [[$2;]]
    )],
    [
      AC_DEFINE([$3], [], [Define 1 if has $4])
      AC_MSG_RESULT([yes])
    ],
    [
      AC_MSG_RESULT([no])
    ]
  )
])
