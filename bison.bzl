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

"""Bazel build rules for GNU Bison.

```python
load("@io_bazel_rules_m4//:m4.bzl", "m4_register_toolchains")
m4_register_toolchains()

load("@io_bazel_rules_bison//:bison.bzl", "bison_register_toolchains")
bison_register_toolchains()
```
"""

load(
    "@io_bazel_rules_m4//m4:toolchain.bzl",
    _M4_TOOLCHAIN = "M4_TOOLCHAIN",
    _m4_context = "m4_context",
)
load(
    "//bison:toolchain.bzl",
    _BISON_TOOLCHAIN = "BISON_TOOLCHAIN",
    _bison_context = "bison_context",
)

_LATEST = "3.2.2"

_VERSION_URLS = {
    "3.2.2": {
        "urls": ["https://ftp.gnu.org/gnu/bison/bison-3.2.2.tar.xz"],
        "sha256": "6f950f24e4d0745c7cc870e36d04f4057133ce0f31d6b4564e6f510a7d3ffafa",
    },
}

BISON_VERSIONS = list(_VERSION_URLS)

_SRC_EXT = {
    "c": "c",
    "c++": "cc",
    "java": "java",
}

_HDR_EXT = {
    "c": "h",
    "c++": "hh",
}

def _bison_parser_impl(ctx):
    m4 = _m4_context(ctx)
    bison = _bison_context(ctx)

    out_src_ext = _SRC_EXT[ctx.attr.language]

    out_src = ctx.actions.declare_file("{}.{}".format(ctx.attr.name, out_src_ext))
    out_xml = ctx.actions.declare_file("{}_report.xml".format(ctx.attr.name))
    out_dot = ctx.actions.declare_file("{}_report.dot".format(ctx.attr.name))
    out_txt = ctx.actions.declare_file("{}_report.txt".format(ctx.attr.name))

    parser_files = [out_src]
    report_files = [out_xml, out_dot, out_txt]

    inputs = m4.inputs + bison.inputs + ctx.files.src

    args = ctx.actions.args()
    args.add_all([
        "-Wall",
        "--language=" + ctx.attr.language,
        "--output=" + out_src.path,
        "--report=all",
        "--report-file=" + out_txt.path,
        "--graph=" + out_dot.path,
        "--xml=" + out_xml.path,
    ])

    if ctx.attr.language != "java":
        out_hdr_ext = _HDR_EXT[ctx.attr.language]
        out_hdr = ctx.actions.declare_file("{}.{}".format(ctx.attr.name, out_hdr_ext))
        parser_files.append(out_hdr)
        args.add("--defines=" + out_hdr.path)

    if ctx.attr.skeleton:
        args.add("--skeleton=" + ctx.file.skeleton.path)
        inputs += ctx.files.skeleton

    args.add_all(ctx.attr.opts)
    args.add(ctx.file.src.path)

    ctx.actions.run(
        executable = bison.executable,
        arguments = [args],
        inputs = inputs,
        outputs = parser_files + report_files,
        input_manifests = bison.input_manifests + m4.input_manifests,
        env = m4.env + bison.env,
        tools = [bison.executable, m4.executable],
        mnemonic = "Bison",
        progress_message = "Generating Bison parser {} (from {})".format(ctx.label, ctx.attr.src.label),
    )
    return [
        DefaultInfo(
            files = depset(parser_files),
        ),
        OutputGroupInfo(
            bison_report = report_files,
        ),
    ]

bison_parser = rule(
    _bison_parser_impl,
    attrs = {
        "src": attr.label(
            mandatory = True,
            allow_single_file = [".y", ".yy", ".y++", ".yxx", ".ypp"],
        ),
        "opts": attr.string_list(
            allow_empty = True,
        ),
        "language": attr.string(
            default = "c",
            values = ["c", "c++", "java"],
        ),
        "skeleton": attr.label(
            allow_single_file = True,
        ),
    },
    toolchains = [_BISON_TOOLCHAIN, _M4_TOOLCHAIN],
)
"""Generate a Bison parser implementation from Yacc-ish source.

```python
load("@io_bazel_rules_bison//:bison.bzl", "bison_parser")
bison_parser(
    name = "hello",
    src = "hello.y",
)
cc_binary(
    name = "hello_bin",
    srcs = [":hello"],
)
```
"""

def _check_version(version):
    if version not in _VERSION_URLS:
        fail("GNU Bison version {} not supported by rules_bison.".format(repr(version)))

def _bison_download(ctx):
    version = ctx.attr.version
    _check_version(version)
    source = _VERSION_URLS[version]

    ctx.download_and_extract(
        url = source["urls"],
        sha256 = source["sha256"],
        stripPrefix = "bison-{}".format(version),
    )

    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(name = repr(ctx.name)))
    ctx.symlink(ctx.attr._overlay_BUILD, "BUILD.bazel")
    ctx.symlink(ctx.attr._overlay_bin_BUILD, "bin/BUILD.bazel")
    ctx.symlink(ctx.attr._overlay_configmake_h, "stub-config/configmake.h")
    ctx.template("stub-config/config.h", ctx.attr._overlay_config_h, {
        "{VERSION}": version,
    })

    # Hardcode getprogname() to "bison" to avoid digging into the gnulib shims.
    ctx.template("lib/error.c", "lib/error.c", substitutions = {
        "#define program_name getprogname ()": '#define program_name "bison"',
    }, executable = False)

bison_download = repository_rule(
    _bison_download,
    attrs = {
        "version": attr.string(mandatory = True),
        "_overlay_BUILD": attr.label(
            default = "@io_bazel_rules_bison//bison/internal:overlay/bison.BUILD",
            single_file = True,
        ),
        "_overlay_bin_BUILD": attr.label(
            default = "@io_bazel_rules_bison//bison/internal:overlay/bison_bin.BUILD",
            single_file = True,
        ),
        "_overlay_config_h": attr.label(
            default = "@io_bazel_rules_bison//bison/internal:overlay/config.h",
            single_file = True,
        ),
        "_overlay_configmake_h": attr.label(
            default = "@io_bazel_rules_bison//bison/internal:overlay/configmake.h",
            single_file = True,
        ),
    },
)

def bison_register_toolchains(version = _LATEST):
    _check_version(version)
    repo_name = "bison_v{}".format(version)
    if repo_name not in native.existing_rules().keys():
        bison_download(
            name = repo_name,
            version = version,
        )
    native.register_toolchains("@io_bazel_rules_bison//bison/toolchains:v{}_toolchain".format(version))
