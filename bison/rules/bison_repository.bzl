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
load(
    "//bison/internal:versions.bzl",
    "VERSION_URLS",
    "custom_version_urls",
)

_BISON_LIB_HDRS = [
    "get-errno.c",
    "get-errno.h",
    "path-join.c",
    "path-join.h",
]

_BISON_BUILD = """
load("@rules_cc//cc:cc_library.bzl", "cc_library")

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

config_setting(
    name = "cc_compiler_clang",
    flag_values = {{"@bazel_tools//tools/cpp:compiler": "clang"}},
    visibility = ["//:__subpackages__"],
)

config_setting(
    name = "cc_compiler_gcc",
    flag_values = {{"@bazel_tools//tools/cpp:compiler": "gcc"}},
    visibility = ["//:__subpackages__"],
)

config_setting(
    name = "cc_compiler_msvc",
    flag_values = {{"@bazel_tools//tools/cpp:compiler": "msvc-cl"}},
    visibility = ["//:__subpackages__"],
)

BISON_COPTS = select({{
    ":cc_compiler_msvc": [
         # C4116: unnamed type definition in parentheses
        "/wd4116",
    ],
    ":cc_compiler_clang": [
        "-std=c99",
        "-Wno-unused-but-set-variable",
    ],
    ":cc_compiler_gcc": ["-std=c99"],
    "//conditions:default": [],
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
load("@rules_cc//cc:cc_binary.bzl", "cc_binary")

filegroup(
    name = "bison_runfiles",
    srcs = [
        "//:bison_data",
        "@rules_m4//m4:current_m4_toolchain",
    ],
)

BISON_LINKOPTS = select({{
    "//:cc_compiler_msvc": [
        # LNK4001: no object files specified; libraries used
        "/IGNORE:4001",
    ],
    "//conditions:default": [],
}})

cc_binary(
    name = "bison",
    data = [":bison_runfiles"],
    visibility = ["//visibility:public"],
    deps = ["//:bison_lib"],
    linkopts = BISON_LINKOPTS + {EXTRA_LINKOPTS},
)
"""

_RULES_BISON_INTERNAL_BUILD = """
load("@rules_bison//bison/rules:bison_toolchain_info.bzl", "bison_toolchain_info")

bison_toolchain_info(
    name = "toolchain_info",
    bison_tool = "//bin:bison",
    visibility = ["//visibility:public"],
)
"""

def _bison_repository(ctx):
    version = ctx.attr.version
    extra_copts = ctx.attr.extra_copts

    version_urls = VERSION_URLS
    if ctx.attr.http_mirrors or ctx.attr.extra_http_mirrors:
        version_urls = custom_version_urls(
            ctx.attr.http_mirrors,
            ctx.attr.extra_http_mirrors,
        )
    source = version_urls[version]

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
    ctx.file("bin/BUILD.bazel", _BISON_BIN_BUILD.format(
        EXTRA_LINKOPTS = ctx.attr.extra_linkopts,
    ))
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
        "extra_linkopts": attr.string_list(
            doc = "Additional linker options to use when building GNU Bison.",
        ),
        "extra_http_mirrors": attr.string_list(
            doc = """
Additional HTTP mirrors of the GNU Bison source archives.

These mirrors will be appended to the list of default GNU mirrors.
""",
        ),
        "http_mirrors": attr.string_list(
            doc = """
If set then this value will be used instead of the default HTTP mirror list.

The `extra_http_mirrors` attribute will be appended to this list.
""",
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
