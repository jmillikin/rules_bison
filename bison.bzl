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

load("@io_bazel_rules_m4//:m4.bzl", "M4_TOOLCHAIN")

_LATEST = "3.2.2"

_VERSION_URLS = {
    "3.2.2": {
        "urls": ["https://ftp.gnu.org/gnu/bison/bison-3.2.2.tar.xz"],
        "sha256": "6f950f24e4d0745c7cc870e36d04f4057133ce0f31d6b4564e6f510a7d3ffafa",
    },
}

BISON_TOOLCHAIN = "@io_bazel_rules_bison//bison:toolchain_type"

BISON_VERSIONS = list(_VERSION_URLS)

def _bison_parser(ctx):
    m4 = ctx.toolchains[M4_TOOLCHAIN].m4
    bison = ctx.toolchains[BISON_TOOLCHAIN].bison

    out_src_ext = {
        "y": "c",
        "yy": "cc",
        "y++": "c++",
        "yxx": "cxx",
        "cpp": "cpp",
    }[ctx.file.src.extension]
    out_hdr_ext = {
        "y": "h",
        "yy": "hh",
        "y++": "h++",
        "yxx": "hxx",
        "cpp": "hpp",
    }[ctx.file.src.extension]

    out_src = ctx.actions.declare_file("{}.{}".format(ctx.attr.name, out_src_ext))
    out_hdr = ctx.actions.declare_file("{}.{}".format(ctx.attr.name, out_hdr_ext))

    ctx.actions.run(
        executable = bison.executable,
        arguments = ["--output=" + out_src.path, "--defines", ctx.file.src.path],
        inputs = [ctx.file.src] + m4.inputs + bison.inputs,
        outputs = [out_src, out_hdr],
        input_manifests = m4.input_manifests + bison.input_manifests,
        env = m4.env(ctx) + bison.env(ctx),
        mnemonic = "Bison",
        progress_message = "Generating Bison parser {} (from {})".format(ctx.label, ctx.attr.src.label),
    )
    return DefaultInfo(
        files = depset([out_src, out_hdr]),
    )

bison_parser = rule(
    _bison_parser,
    attrs = {
        "src": attr.label(
            mandatory = True,
            single_file = True,
            allow_files = [".y", ".yy", ".y++", ".yxx", ".ypp"],
        ),
    },
    toolchains = [BISON_TOOLCHAIN, M4_TOOLCHAIN],
)

def _bison_env(ctx):
    m4 = ctx.toolchains[M4_TOOLCHAIN].m4
    internal = ctx.toolchains[BISON_TOOLCHAIN]._internal
    return {
        "M4": m4.executable.path,
        "BISON_PKGDATADIR": internal.pkgdatadir,
    }

def _bison_toolchain(ctx):
    (inputs, _, input_manifests) = ctx.resolve_command(
        command = "bison",
        tools = [ctx.attr.bison],
    )

    workspace_root = ctx.attr.bison.label.workspace_root
    pkgdatadir = "{}.runfiles/{}/data".format(
        ctx.executable.bison.path,
        workspace_root[len("external/"):],
    )

    return [
        platform_common.ToolchainInfo(
            bison = struct(
                executable = ctx.executable.bison,
                inputs = inputs,
                input_manifests = input_manifests,
                env = _bison_env,
            ),
            _internal = struct(
                pkgdatadir = pkgdatadir,
            ),
        ),
    ]

bison_toolchain = rule(
    _bison_toolchain,
    attrs = {
        "bison": attr.label(
            executable = True,
            cfg = "host",
        ),
    },
)

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
        "version": version,
    })

bison_download = repository_rule(
    _bison_download,
    attrs = {
        "version": attr.string(mandatory = True),
        "_overlay_BUILD": attr.label(
            default = "@io_bazel_rules_bison//internal:overlay/bison_BUILD",
            single_file = True,
        ),
        "_overlay_bin_BUILD": attr.label(
            default = "@io_bazel_rules_bison//internal:overlay/bison_bin_BUILD",
            single_file = True,
        ),
        "_overlay_config_h": attr.label(
            default = "@io_bazel_rules_bison//internal:overlay/config.h",
            single_file = True,
        ),
        "_overlay_configmake_h": attr.label(
            default = "@io_bazel_rules_bison//internal:overlay/configmake.h",
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
    native.register_toolchains("@io_bazel_rules_bison//toolchains:v{}_toolchain".format(version))
