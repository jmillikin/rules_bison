# Copyright 2018 the rules_bison authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

cc_library(
    name = "config_h",
    hdrs = select({
        "@bazel_tools//src/conditions:darwin": glob(["config-darwin/*.h"]),
        "@bazel_tools//src/conditions:windows": glob(["config-windows/*.h"]),
        "@bazel_tools//src/conditions:openbsd": glob(["config-openbsd/*.h"]),
        "//conditions:default": glob(["config-linux/*.h"]),
    }),
    includes = select({
        "@bazel_tools//src/conditions:darwin": [
            "config-darwin",
        ],
        "@bazel_tools//src/conditions:windows": [
            "config-windows",
        ],
        "@bazel_tools//src/conditions:openbsd": [
            "config-openbsd",
        ],
        "//conditions:default": [
            "config-linux",
        ],
    }),
    visibility = ["//:__pkg__"],
)

cc_library(
    name = "gnulib_windows_shims",
    hdrs = glob(["config-windows/shim-libc/**/*"]),
    includes = ["config-windows/shim-libc"],
    deps = [":config_h"],
)

_GNULIB_HDRS = glob([
    "lib/*.h",
    "lib/bitset/*.h",
])

_GNULIB_SRCS = glob([
    "lib/abitset.c",
    "lib/argmatch.c",
    "lib/asnprintf.c",
    "lib/basename-lgpl.c",
    "lib/bitset.c",
    "lib/bitset/*.c",
    "lib/bitset_stats.c",
    "lib/bitsetv-print.c",
    "lib/bitsetv.c",
    "lib/c-strcasecmp.c",
    "lib/close-stream.c",
    "lib/closeout.c",
    "lib/concat-filename.c",
    "lib/dup-safer.c",
    "lib/ebitset.c",
    "lib/error.c",
    "lib/exitfail.c",
    "lib/fatal-signal.c",
    "lib/fd-safer.c",
    "lib/fopen-safer.c",
    "lib/fpending.c",
    "lib/get-errno.c",
    "lib/gethrxtime.c",
    "lib/gettime.c",
    "lib/gl_array_list.c",
    "lib/hash.c",
    "lib/lbitset.c",
    "lib/localcharset.c",
    "lib/mbswidth.c",
    "lib/obstack.c",
    "lib/obstack_printf.c",
    "lib/path-join.c",
    "lib/pipe-safer.c",
    "lib/printf-args.c",
    "lib/printf-frexp.c",
    "lib/printf-frexpl.c",
    "lib/printf-parse.c",
    "lib/progname.c",
    "lib/quotearg.c",
    "lib/spawn-pipe.c",
    "lib/strverscmp.c",
    "lib/timevar.c",
    "lib/vasnprintf.c",
    "lib/vbitset.c",
    "lib/wait-process.c",
    "lib/xalloc-die.c",
    "lib/xconcat-filename.c",
    "lib/xmalloc.c",
    "lib/xmemdup0.c",
    "lib/xstrndup.c",
])

_GNULIB_DARWIN_SRCS = []

_GNULIB_LINUX_SRCS = glob([
    "lib/bitrotate.c",
    "lib/c-ctype.c",
    "lib/getprogname.c",
    "lib/gl_list.c",
    "lib/gl_xlist.c",
    "lib/sig-handler.c",
    "lib/xsize.c",
    "lib/xtime.c",
])

_GNULIB_WINDOWS_SRCS = [
    "lib/cloexec.c",
    "lib/close.c",
    "lib/dup-safer-flag.c",
    "lib/dup2.c",
    "lib/fcntl.c",
    "lib/fd-safer-flag.c",
    "lib/fseterr.c",
    "lib/fstat.c",
    "lib/getdtablesize.c",
    "lib/getopt.c",
    "lib/getopt1.c",
    "lib/getprogname.c",
    "lib/getrusage.c",
    "lib/gettimeofday.c",
    "lib/malloc.c",
    "lib/mbrtowc.c",
    "lib/mbsinit.c",
    "lib/msvc-inval.c",
    "lib/msvc-nothrow.c",
    "lib/pipe2-safer.c",
    "lib/pipe2.c",
    "lib/raise.c",
    "lib/sigaction.c",
    "lib/sigprocmask.c",
    "lib/snprintf.c",
    "lib/stpcpy.c",
    "lib/strerror-override.c",
    "lib/strerror.c",
    "lib/strerror_r.c",
    "lib/strndup.c",
    "lib/uniwidth/cjk.h",
    "lib/uniwidth/width.c",
    "lib/waitpid.c",
    "lib/wcwidth.c",
]

_COPTS = select({
    "@bazel_tools//src/conditions:windows_msvc": [
        # By default, MSVC doesn't fail or even warn when an undefined function
        # is called. This check is vital when building gnulib because of how it
        # shims in its own malloc functions.
        #
        # C4013: 'function' undefined; assuming extern returning int
        "/we4013",

        # Silence this style lint because gnulib freely violates it, and chances
        # of the GNU developers ever caring about MSVC style guidelines are low.
        #
        # C4116: unnamed type definition in parentheses
        "/wd4116",
    ],
    "//conditions:default": [],
})

cc_library(
    name = "gnulib",
    # Include _GNULIB_HDRS in the sources list to work around a bug in C++
    # strict header inclusion checking when building without a sandbox.
    #
    # https://github.com/bazelbuild/bazel/issues/3828
    # https://github.com/bazelbuild/bazel/issues/6337
    srcs = _GNULIB_SRCS + _GNULIB_HDRS + select({
        "@bazel_tools//src/conditions:darwin": _GNULIB_DARWIN_SRCS,
        "@bazel_tools//src/conditions:windows": _GNULIB_WINDOWS_SRCS,
        "//conditions:default": _GNULIB_LINUX_SRCS,
    }),
    hdrs = _GNULIB_HDRS,
    copts = _COPTS + ["-DHAVE_CONFIG_H"] + {GNULIB_EXTRA_COPTS},
    includes = ["lib"],
    textual_hdrs = [
        "lib/printf-frexp.c",
    ],
    visibility = ["//:__pkg__"],
    deps = [
        ":config_h",
        "//:timevar_def",
    ] + select({
        "@bazel_tools//src/conditions:windows": [":gnulib_windows_shims"],
        "//conditions:default": [],
    }),
)
