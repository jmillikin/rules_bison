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

"""Helpers for running Bison as a build action."""

load(
    "//bison:toolchain_type.bzl",
    "BISON_TOOLCHAIN_TYPE",
    "bison_toolchain",
)

_M4_TOOLCHAIN_TYPE = "@rules_m4//m4:toolchain_type"

_SRC_EXT = {
    "c": "c",
    "c++": "cc",
    "java": "java",
}

BISON_ACTION_TOOLCHAINS = [
    _M4_TOOLCHAIN_TYPE,
    BISON_TOOLCHAIN_TYPE,
]

_BISON_ACTION_ATTRS = {
    "bison_options": attr.string_list(),
    "skeleton": attr.label(
        allow_single_file = True,
    ),
    "_m4_deny_shell": attr.label(
        executable = True,
        default = "//bison/internal:m4_deny_shell",
        cfg = "host",
    ),
}

def bison_action_attrs(rule_attrs):
    rule_attrs.update(_BISON_ACTION_ATTRS)
    return rule_attrs

def bison_action(ctx, language):
    bison = bison_toolchain(ctx)

    out_src_ext = _SRC_EXT[language]

    out_src = ctx.actions.declare_file("{}.{}".format(ctx.attr.name, out_src_ext))
    out_xml = ctx.actions.declare_file("{}_report.xml".format(ctx.attr.name))
    out_dot = ctx.actions.declare_file("{}_report.dot".format(ctx.attr.name))
    out_txt = ctx.actions.declare_file("{}_report.txt".format(ctx.attr.name))

    parser_files = [out_src]
    report_files = [out_xml, out_dot, out_txt]

    inputs = list(ctx.files.src)

    args = ctx.actions.args()
    args.add_all([
        "-Wall",
        "--language=" + language,
        "--output=" + out_src.path,
        "--report=all",
        "--report-file=" + out_txt.path,
        "--graph=" + out_dot.path,
        "--xml=" + out_xml.path,
    ])

    out_hdr = None
    if language != "java":
        out_hdr = ctx.actions.declare_file("{}.h".format(ctx.attr.name))
        parser_files.append(out_hdr)
        args.add("--defines=" + out_hdr.path)

    if ctx.attr.skeleton:
        args.add("--skeleton=" + ctx.file.skeleton.path)
        inputs.append(ctx.file.skeleton)

    args.add_all(ctx.attr.bison_options)
    args.add(ctx.file.src.path)

    ctx.actions.run(
        executable = bison.bison_tool,
        arguments = [args],
        inputs = depset(direct = inputs),
        tools = [ctx.executable._m4_deny_shell],
        outputs = parser_files + report_files,
        env = dict(
            bison.bison_env,
            M4_SYSCMD_SHELL = ctx.executable._m4_deny_shell.path,
        ),
        mnemonic = "Bison",
        progress_message = "Bison {}".format(ctx.label),
    )
    return struct(
        source = out_src,
        header = out_hdr,
        outs = depset(direct = parser_files),
        report_files = depset(direct = report_files),
    )
