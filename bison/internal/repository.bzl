# Copyright 2019 the rules_bison authors.
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

load(
    "@rules_bison//bison/internal:versions.bzl",
    _VERSION_URLS = "VERSION_URLS",
    _check_version = "check_version",
)
load(
    "@rules_bison//bison/internal:gnulib/gnulib.bzl",
    _gnulib_overlay = "gnulib_overlay",
)

_BISON_LIB_HDRS = [
    "get-errno.c",
    "get-errno.h",
    "path-join.c",
    "path-join.h",
]

_BISON_BUILD = """
filegroup(
    name = "bison_data",
    srcs = glob(["data/**/*"]),
    visibility = ["//bin:__pkg__"],
)

cc_library(
    name = "timevar_def",
    textual_hdrs = ["lib/timevar.def"],
    visibility = ["//gnulib:__pkg__"],
)

BISON_SCANNER_SRCS = glob(
    ["src/scan-*.c"],
    exclude=["src/scan-*-c.c"],
)

BISON_SRC_SRCS = glob(
    ["src/*.c", "src/*.h"],
    exclude = BISON_SCANNER_SRCS,
)

BISON_LIB_SRCS = glob(["bison-lib/*"])

cc_library(
    name = "bison_lib",
    srcs = BISON_SRC_SRCS + BISON_LIB_SRCS,
    includes = [".", "bison-lib"],
    strip_include_prefix = "bison-lib",
    textual_hdrs = BISON_SCANNER_SRCS,
    visibility = ["//bin:__pkg__"],
    deps = [
        "//gnulib",
        "//gnulib:config_h",
    ],
)
"""

_BISON_BIN_BUILD = """
filegroup(
    name = "bison_runfiles",
    srcs = [
        "//:bison_data",
        "@rules_m4//m4:current_m4_toolchain",
    ],
)
cc_binary(
    name = "bison",
    data = [":bison_runfiles"],
    visibility = ["//visibility:public"],
    deps = ["//:bison_lib"],
)
"""

def _bison_repository(ctx):
    version = ctx.attr.version
    _check_version(version)
    source = _VERSION_URLS[version]

    ctx.download_and_extract(
        url = source["urls"],
        sha256 = source["sha256"],
        stripPrefix = "bison-{}".format(version),
    )

    _gnulib_overlay(ctx, bison_version = version)

    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(name = repr(ctx.name)))
    ctx.file("BUILD.bazel", _BISON_BUILD)
    ctx.file("bin/BUILD.bazel", _BISON_BIN_BUILD)

    # A couple headers in lib/ get included with angle brackets. To avoid
    # putting all of lib/ in -isystem (which pollutes the gnulib build on
    # non-sandboxed builds), reference them from their own subdir.
    for hdr in _BISON_LIB_HDRS:
        ctx.symlink("lib/" + hdr, "bison-lib/" + hdr)

bison_repository = repository_rule(
    _bison_repository,
    attrs = {
        "version": attr.string(mandatory = True),
        "_gnulib_build": attr.label(
            default = "@rules_bison//bison/internal:gnulib/gnulib.BUILD",
            allow_single_file = True,
        ),
        "_gnulib_config_darwin_h": attr.label(
            default = "//bison/internal:gnulib/config-darwin.h",
            allow_single_file = True,
        ),
        "_gnulib_config_linux_h": attr.label(
            default = "//bison/internal:gnulib/config-linux.h",
            allow_single_file = True,
        ),
        "_gnulib_config_windows_h": attr.label(
            default = "//bison/internal:gnulib/config-windows.h",
            allow_single_file = True,
        ),
    },
)
