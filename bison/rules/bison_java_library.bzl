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

"""Definition of the `bison_java_library` build rule."""

load(
    "//bison/internal:bison_action.bzl",
    "BISON_ACTION_TOOLCHAINS",
    "bison_action",
    "bison_action_attrs",
)

def _bison_java_library(ctx):
    result = bison_action(ctx, "java")
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
    implementation = _bison_java_library,
    attrs = bison_action_attrs({
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
    toolchains = BISON_ACTION_TOOLCHAINS,
)
