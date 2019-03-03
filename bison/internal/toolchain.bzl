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

TOOLCHAIN_TYPE = "@rules_bison//bison:toolchain_type"

ToolchainInfo = provider(fields = ["files", "vars", "bison_executable"])

def _bison_toolchain_info(ctx):
    bison_runfiles = ctx.attr.bison[DefaultInfo].default_runfiles.files
    toolchain = ToolchainInfo(
        bison_executable = ctx.executable.bison,
        files = depset(
            direct = [ctx.executable.bison],
            transitive = [bison_runfiles],
        ),
        vars = {
            "BISON": ctx.executable.bison.path,
        },
    )
    return [
        platform_common.ToolchainInfo(bison_toolchain = toolchain),
        platform_common.TemplateVariableInfo(toolchain.vars),
    ]

bison_toolchain_info = rule(
    _bison_toolchain_info,
    attrs = {
        "bison": attr.label(
            mandatory = True,
            executable = True,
            cfg = "host",
        ),
    },
    provides = [
        platform_common.ToolchainInfo,
        platform_common.TemplateVariableInfo,
    ],
)

def _bison_toolchain_alias(ctx):
    toolchain = ctx.toolchains[TOOLCHAIN_TYPE].bison_toolchain
    return [
        DefaultInfo(files = toolchain.files),
        toolchain,
        platform_common.TemplateVariableInfo(toolchain.vars),
    ]

bison_toolchain_alias = rule(
    _bison_toolchain_alias,
    toolchains = [TOOLCHAIN_TYPE],
    provides = [
        DefaultInfo,
        ToolchainInfo,
        platform_common.TemplateVariableInfo,
    ],
)
