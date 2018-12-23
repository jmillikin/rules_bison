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

load(
    "@io_bazel_rules_m4//m4:toolchain.bzl",
    _M4_TOOLCHAIN = "M4_TOOLCHAIN",
    _m4_context = "m4_context",
)

BISON_TOOLCHAIN = "@io_bazel_rules_bison//bison:toolchain_type"

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
            _bison_internal = struct(
                executable = ctx.executable.bison,
                inputs = depset(inputs + [ctx.executable._m4_deny_shell]),
                input_manifests = input_manifests,
                pkgdatadir = pkgdatadir,
                m4_deny_shell = ctx.executable._m4_deny_shell,
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
        "_m4_deny_shell": attr.label(
            executable = True,
            default = "//bison/internal:m4_deny_shell",
            cfg = "host",
        ),
    },
)

def bison_context(ctx):
    toolchain = ctx.toolchains[BISON_TOOLCHAIN]
    impl = toolchain._bison_internal
    m4 = _m4_context(ctx)
    return struct(
        toolchain = toolchain,
        executable = impl.executable,
        inputs = impl.inputs,
        input_manifests = impl.input_manifests,
        env = {
            "M4": m4.executable.path,
            "BISON_PKGDATADIR": impl.pkgdatadir,
            # By default, rules_m4 will forbid all shell commands
            # from M4. Bison needs this slightly loosened, becauae
            # its warning messages are implemented by m4_syscmd(cat).
            "M4_SYSCMD_SHELL": impl.m4_deny_shell.path,
        },
    )
