AC_DEFUN([AX_TIMERS], [
  timer_found=no

  AC_MSG_CHECKING([for mach timer functions])
  AC_LANG_PUSH([C])
  AC_COMPILE_IFELSE(
    [
      AC_LANG_PROGRAM(
        [[#include <mach/mach_time.h>]],
        [[mach_absolute_time();]]
      )
    ],
    [
      AC_MSG_RESULT([yes])
      AC_SUBST([osdep_timer], [timer-darwin])
      timer_found=yes
    ],
    [
      AC_MSG_RESULT([no])
    ]
  )
  AC_LANG_POP([C])

  AS_IF([test "$timer_found" = "no"], [
    AC_MSG_CHECKING([for windows timer functions])
    AC_LANG_PUSH([C])
    AC_COMPILE_IFELSE(
      [
        AC_LANG_PROGRAM(
          [[#include <mmsystem.h>]],
          [[Sleep(1);]]
        )
      ],
      [
        AC_MSG_RESULT([yes])
        AC_SUBST([osdep_timer], [timer-win32])
        timer_found=yes
      ],
      [
        AC_MSG_RESULT([no])
      ]
    )
    AC_LANG_POP([C])
  ])

  AS_IF([test "$timer_found" = "no"], [
    AC_MSG_CHECKING([for linux timer functions])
    AC_LANG_PUSH([C])
    AC_COMPILE_IFELSE(
      [
        AC_LANG_PROGRAM(
          [[#include <unistd.h>]],
          [[usleep(1);]]
        )
      ],
      [
        AC_MSG_RESULT([yes])
        AC_SUBST([osdep_timer], [timer-linux])
        timer_found=yes
      ],
      [
        AC_MSG_RESULT([no])
      ]
    )
    AC_LANG_POP([C])
  ])

  AS_IF([test "$timer_found" = "no"], [
    AC_MSG_ERROR([No timer implementation found. Maybe your platform is not (yet) supporded.])
  ])
])
