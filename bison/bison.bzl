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

load("@rules_bison//bison/internal:repository.bzl", _bison_repository = "bison_repository")
load("@rules_bison//bison/internal:toolchain.bzl", _BISON_TOOLCHAIN_TYPE = "BISON_TOOLCHAIN_TYPE")
load("@rules_bison//bison/internal:versions.bzl", "DEFAULT_VERSION", "check_version")
load("@rules_m4//m4:m4.bzl", "M4_TOOLCHAIN_TYPE")

BISON_TOOLCHAIN_TYPE = _BISON_TOOLCHAIN_TYPE
bison_repository = _bison_repository

def bison_toolchain(ctx):
    return ctx.toolchains[BISON_TOOLCHAIN_TYPE].bison_toolchain

# buildifier: disable=unnamed-macro
def bison_register_toolchains(version = DEFAULT_VERSION, extra_copts = []):
    check_version(version)
    repo_name = "bison_v{}".format(version)
    if repo_name not in native.existing_rules().keys():
        bison_repository(
            name = repo_name,
            version = version,
            extra_copts = extra_copts,
        )
    native.register_toolchains("@rules_bison//bison/toolchains:v{}".format(version))

_SRC_EXT = {
    "c": "c",
    "c++": "cc",
    "java": "java",
}

_COMMON_ATTR = {
    "bison_options": attr.string_list(),
    "skeleton": attr.label(
        allow_single_file = True,
    ),
    "_m4_deny_shell": attr.label(
        executable = True,
        default = "@rules_bison//bison/internal:m4_deny_shell",
        cfg = "host",
    ),
}

_BISON_RULE_TOOLCHAINS = [
    M4_TOOLCHAIN_TYPE,
    BISON_TOOLCHAIN_TYPE,
]

def _bison_attrs(rule_attrs):
    rule_attrs.update(_COMMON_ATTR)
    return rule_attrs

def _bison_common(ctx, language):
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

def _bison(ctx):
    if ctx.file.src.extension == "y":
        language = "c"
    else:
        language = "c++"
    result = _bison_common(ctx, language)
    return [
        DefaultInfo(files = result.outs),
        OutputGroupInfo(bison_report = result.report_files),
    ]

bison = rule(
    _bison,
    attrs = _bison_attrs({
        "src": attr.label(
            mandatory = True,
            allow_single_file = [".y", ".yy", ".y++", ".yxx", ".ypp"],
        ),
    }),
    provides = [
        DefaultInfo,
        OutputGroupInfo,
    ],
    toolchains = _BISON_RULE_TOOLCHAINS,
)

def _cc_library(ctx, bison_result):
    cc_toolchain = ctx.attr._cc_toolchain[cc_common.CcToolchainInfo]

    cc_deps = cc_common.merge_cc_infos(cc_infos = [
        dep[CcInfo]
        for dep in ctx.attr.deps
    ])

    cc_feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.attr.features,
    )

    (cc_compilation_context, cc_compilation_outputs) = cc_common.compile(
        name = ctx.attr.name,
        actions = ctx.actions,
        cc_toolchain = cc_toolchain,
        feature_configuration = cc_feature_configuration,
        srcs = [bison_result.source],
        public_hdrs = [bison_result.header],
        compilation_contexts = [cc_deps.compilation_context],
    )

    (cc_linking_context, cc_linking_outputs) = cc_common.create_linking_context_from_compilation_outputs(
        name = ctx.attr.name,
        actions = ctx.actions,
        feature_configuration = cc_feature_configuration,
        cc_toolchain = cc_toolchain,
        compilation_outputs = cc_compilation_outputs,
        linking_contexts = [cc_deps.linking_context],
    )

    outs = []
    if cc_linking_outputs.library_to_link.static_library:
        outs.append(cc_linking_outputs.library_to_link.static_library)
    if cc_linking_outputs.library_to_link.dynamic_library:
        outs.append(cc_linking_outputs.library_to_link.dynamic_library)

    return struct(
        outs = depset(direct = outs),
        cc_info = CcInfo(
            compilation_context = cc_compilation_context,
            linking_context = cc_linking_context,
        ),
    )

def _bison_cc_library(ctx):
    if ctx.file.src.extension == "y":
        language = "c"
    else:
        language = "c++"
    result = _bison_common(ctx, language)
    cc_lib = _cc_library(ctx, result)
    return [
        DefaultInfo(files = cc_lib.outs),
        cc_lib.cc_info,
        OutputGroupInfo(bison_report = result.report_files),
    ]

bison_cc_library = rule(
    _bison_cc_library,
    attrs = _bison_attrs({
        "src": attr.label(
            mandatory = True,
            allow_single_file = [".y", ".yy", ".y++", ".yxx", ".ypp"],
        ),
        "deps": attr.label_list(
            providers = [CcInfo],
        ),
        "_cc_toolchain": attr.label(
            default = "@bazel_tools//tools/cpp:current_cc_toolchain",
        ),
    }),
    provides = [
        CcInfo,
        DefaultInfo,
        OutputGroupInfo,
    ],
    toolchains = _BISON_RULE_TOOLCHAINS,
    fragments = ["cpp"],
)

def _bison_java_library(ctx):
    result = _bison_common(ctx, "java")
    out_jar = ctx.actions.declare_file("lib{}.jar".format(ctx.attr.name))

    compile_kwargs = {}

    java_toolchain = ctx.attr._java_toolchain[java_common.JavaToolchainInfo]
    if not hasattr(java_toolchain, "java_runtime"):
        host_javabase = ctx.attr._host_javabase[java_common.JavaRuntimeInfo]
        compile_kwargs["host_javabase"] = host_javabase

    java_info = java_common.compile(
        ctx,
        java_toolchain = java_toolchain,
        source_files = [result.source],
        output = out_jar,
        deps = ctx.attr.deps,
        **compile_kwargs
    )
    return [
        DefaultInfo(files = depset(direct = [out_jar])),
        java_info,
        OutputGroupInfo(bison_report = result.report_files),
    ]

bison_java_library = rule(
    _bison_java_library,
    attrs = _bison_attrs({
        "src": attr.label(
            mandatory = True,
            allow_single_file = [".y"],
        ),
        "deps": attr.label_list(
            providers = [JavaInfo],
        ),
        "_host_javabase": attr.label(
            default = "@bazel_tools//tools/jdk:current_host_java_runtime",
        ),
        "_java_toolchain": attr.label(
            default = "@bazel_tools//tools/jdk:toolchain",
        ),
    }),
    fragments = ["java"],
    provides = [
        DefaultInfo,
        JavaInfo,
        OutputGroupInfo,
    ],
    toolchains = _BISON_RULE_TOOLCHAINS,
)
