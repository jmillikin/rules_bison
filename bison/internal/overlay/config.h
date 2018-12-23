#include <stdint.h>
#include <stdio.h>
#include <wchar.h>

extern char **environ;

#define _GNU_SOURCE

#define PACKAGE "bison"
#define PACKAGE_BUGREPORT "bug-bison@gnu.org"
#define PACKAGE_COPYRIGHT_YEAR 2018
#define PACKAGE_NAME "GNU Bison"
#define PACKAGE_STRING "GNU Bison {VERSION}"
#define PACKAGE_URL "http://www.gnu.org/software/bison/"
#define PACKAGE_VERSION "{VERSION}"
#define VERSION "{VERSION}"

#define _GL_ARG_NONNULL(x)
#define _GL_ATTRIBUTE_CONST __attribute__ ((const))
#define _GL_ATTRIBUTE_FORMAT_PRINTF(x,y)
#define _GL_ATTRIBUTE_MALLOC __attribute__ ((__malloc__))
#define _GL_ATTRIBUTE_PURE __attribute__ ((pure))
#define _GL_EXTERN_INLINE extern inline
#define _GL_INLINE inline
#define _GL_INLINE_HEADER_BEGIN
#define _GL_INLINE_HEADER_END

#define GNULIB_FOPEN_SAFER 1

#define HAVE_DECL_STRERROR_R 1
#define HAVE_PIPE 1
#define HAVE_STACK_T 1

#define M4 "/bin/false"
#define M4_GNU_OPTION ""

#define UNLOCKED_IO_H

struct obstack;
int obstack_printf(struct obstack *obs, const char *format, ...);
int obstack_vprintf(struct obstack *obs, const char *format, va_list args);
int strverscmp(const char *s1, const char *s2);
int wcwidth(wchar_t wc);
