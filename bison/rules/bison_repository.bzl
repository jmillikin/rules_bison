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

"""Definition of the `bison_repository` repository rule."""

load("//bison/internal:gnulib/gnulib.bzl", "gnulib_overlay")
load("//bison/internal:versions.bzl", "VERSION_URLS")

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

BISON_COPTS = select({{
    "@bazel_tools//src/conditions:windows_msvc": [],
    "//conditions:default": ["-std=c99"],
}})

cc_library(
    name = "bison_bazel_runfiles",
    srcs = ["src/bazel_runfiles.cc"],
    deps = ["@bazel_tools//tools/cpp/runfiles"],
)

cc_library(
    name = "bison_lib",
    srcs = BISON_SRC_SRCS + BISON_LIB_SRCS,
    copts = BISON_COPTS + {EXTRA_COPTS},
    includes = [".", "bison-lib"],
    strip_include_prefix = "bison-lib",
    textual_hdrs = BISON_SCANNER_SRCS,
    visibility = ["//bin:__pkg__"],
    deps = [
        ":bison_bazel_runfiles",
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

_RULES_BISON_INTERNAL_BUILD = """
load("@rules_bison//bison/internal:toolchain_info.bzl", "bison_toolchain_info")

bison_toolchain_info(
    name = "toolchain_info",
    bison_tool = "//bin:bison",
    visibility = ["//visibility:public"],
)
"""

def _bison_repository(ctx):
    version = ctx.attr.version
    extra_copts = ctx.attr.extra_copts
    source = VERSION_URLS[version]

    ctx.download_and_extract(
        url = source["urls"],
        sha256 = source["sha256"],
        stripPrefix = "bison-{}".format(version),
    )

    gnulib_overlay(ctx, bison_version = version, extra_copts = extra_copts)

    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(
        name = repr(ctx.name),
    ))
    ctx.file("BUILD.bazel", _BISON_BUILD.format(EXTRA_COPTS = extra_copts))
    ctx.file("bin/BUILD.bazel", _BISON_BIN_BUILD)
    ctx.file("rules_bison_internal/BUILD.bazel", _RULES_BISON_INTERNAL_BUILD)

    # A couple headers in lib/ get included with angle brackets. To avoid
    # putting all of lib/ in -isystem (which pollutes the gnulib build on
    # non-sandboxed builds), reference them from their own subdir.
    for hdr in _BISON_LIB_HDRS:
        ctx.symlink("lib/" + hdr, "bison-lib/" + hdr)

    # Shim in support for locating $BISON_PKGDATADIR and $M4 via
    # Bazel runfiles if available.
    ctx.patch(ctx.attr._bazel_runfiles_patch)
    ctx.template("src/main.c", "src/main.c", substitutions = {
        "main (int argc, char *argv[])\n{": "\n".join([
            "main (int argc, char *argv[])\n{",
            "void bazel_runfiles_init(const char *argv0);",
            "bazel_runfiles_init(argv[0]);",
        ]),
    })
    ctx.template("src/output.c", "src/output.c", substitutions = {
        'char const *cp = getenv ("BISON_PKGDATADIR");': "\n".join([
            "char *bazel_runfiles_bison_pkgdatadir();",
            "static char *bazel_pkgdatadir_p = NULL;",
            "if (bazel_pkgdatadir_p == NULL) {",
            "bazel_pkgdatadir_p = bazel_runfiles_bison_pkgdatadir(); }",
            "if (bazel_pkgdatadir_p != NULL) { return bazel_pkgdatadir_p; }",
            'char const *cp = getenv ("BISON_PKGDATADIR");',
        ]),
        'char const *m4 = (m4 = getenv ("M4")) ? m4 : M4;': "\n".join([
            "char *bazel_runfiles_m4();",
            "static char *bazel_m4_p = NULL;",
            "if (bazel_m4_p == NULL) {",
            "bazel_m4_p = bazel_runfiles_m4(); }",
            'char const *m4 = bazel_m4_p? bazel_m4_p : (m4 = getenv ("M4")) ? m4 : M4;',
        ]),
    })

bison_repository = repository_rule(
    implementation = _bison_repository,
    doc = """
Repository rule for GNU Bison.

The resulting repository will have a `//bin:bison` executable target.

### Example

```starlark
load("@rules_bison//bison:bison.bzl", "bison_repository")

bison_repository(
    name = "bison_v3.3.2",
    version = "3.3.2",
)
```
""",
    attrs = {
        "version": attr.string(
            doc = "A supported version of GNU Bison.",
            mandatory = True,
            values = sorted(VERSION_URLS),
        ),
        "extra_copts": attr.string_list(
            doc = "Additional C compiler options to use when building GNU Bison.",
        ),
        "_bazel_runfiles_patch": attr.label(
            default = Label("//bison/internal:bazel_runfiles.patch"),
            allow_single_file = True,
        ),
        "_gnulib_build": attr.label(
            default = Label("//bison/internal:gnulib/gnulib.BUILD"),
            allow_single_file = True,
        ),
        "_gnulib_config_darwin_h": attr.label(
            default = Label("//bison/internal:gnulib/config-darwin.h"),
            allow_single_file = True,
        ),
        "_gnulib_config_linux_h": attr.label(
            default = Label("//bison/internal:gnulib/config-linux.h"),
            allow_single_file = True,
        ),
        "_gnulib_config_windows_h": attr.label(
            default = Label("//bison/internal:gnulib/config-windows.h"),
            allow_single_file = True,
        ),
        "_gnulib_config_openbsd_h": attr.label(
            default = Label("//bison/internal:gnulib/config-openbsd.h"),
            allow_single_file = True,
        ),
        "_gnulib_config_freebsd_h": attr.label(
            default = Label("//bison/internal:gnulib/config-freebsd.h"),
            allow_single_file = True,
        ),
    },
)
